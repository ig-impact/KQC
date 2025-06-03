#' User Interface for Data Quality Control Module
#'
#' @param id A unique character string identifying the module instance.
#' @return A Shiny tag list for inclusion in a UI.
kqc_module_ui <- function(id) {
  ns <- shiny::NS(id)

  htmltools::tagList(
    shinyjs::useShinyjs(),

    # Input and action buttons grouped using a Bootstrap layout
    htmltools::div(
      class = "mb-3",
      shiny::textInput(
        ns("uid_input"),
        label = "Submission UID",
        placeholder = "e.g., aVbeC2BBwhRSzrFf3roZ7z",
        value = "aVbeC2BBwhRSzrFf3roZ7z"
      )
    ),

    # Buttons aligned horizontally with spacing
    htmltools::div(
      class = "d-flex gap-2 mb-4",
      shiny::actionButton(
        ns("download_btn"),
        label = "Download Data",
        icon = shiny::icon("download"),
        class = "btn btn-primary"
      ),
      shiny::actionButton(
        ns("validate_btn"),
        label = "Validate Data",
        icon = shiny::icon("check-circle"),
        class = "btn btn-info"
      )
    ),

    # Output report area wrapped in a styled bslib card
    bslib::card(
      full_screen = TRUE,
      bslib::card_header("Validation Report"),
      shiny::uiOutput(ns("report_output"))
    )
  )
}

#' Server Logic for Data Quality Control Module
#'
#' Handles downloading data and validating it using pointblank.
#'
#' @param id A unique character string identifying the module instance.
#' @return A reactive expression returning the validated data frame.
kqc_module_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    rv <- shiny::reactiveValues(
      downloaded_data = NULL,
      download_successful = FALSE,
      validation_report = NULL,
      agent = NULL
    )

    shinyjs::disable("validate_btn")

    shiny::observeEvent(input$download_btn, {
      if (is.null(input$uid_input) || input$uid_input == "") {
        shiny::showNotification(
          "Please enter a valid UID.",
          type = "warning"
        )
        return()
      }

      rv$download_successful <- FALSE
      rv$downloaded_data <- NULL
      rv$validation_report <- NULL
      shinyjs::disable("validate_btn")

      shiny::withProgress(message = "Downloading data...", value = 0, {
        shiny::incProgress(
          0.2,
          detail = paste("Fetching UID:", input$uid_input)
        )

        tryCatch(
          {
            robotoolbox::kobo_setup()
            data <- robotoolbox::kobo_data(input$uid_input)

            rv$downloaded_data <- data
            rv$download_successful <- TRUE
            shinyjs::enable("validate_btn")

            shiny::incProgress(0.7, detail = "Download complete")
            shiny::showNotification(
              "Data downloaded successfully.",
              type = "message"
            )
          },
          error = function(e) {
            shiny::showNotification(
              paste(
                "Failed to download data.",
                "Ensure a valid UID is used and",
                "KOBOTOOLBOX_URL + TOKEN are set in .Renviron.",
                "Details:", e$message
              ),
              type = "error",
              duration = NULL
            )
          }
        )
      })
    })

    shiny::observeEvent(input$validate_btn, {
      if (is.null(rv$downloaded_data)) {
        shiny::showNotification(
          "No data available to validate.",
          type = "error"
        )
        return()
      }

      shiny::withProgress(message = "Validating data...", value = 0, {
        shiny::incProgress(0.2, detail = "Running pointblank checks...")

        tryCatch(
          {
            agent <- pointblank::create_agent(
              tbl = rv$downloaded_data,
              label = "Data Submission Validation Report"
            ) |>
              pointblank::col_exists(columns = c("start", "end", "audit")) |>
              pointblank::col_is_date(columns = "today") |>
              pointblank::col_vals_not_null(columns = "_uuid") |>
              pointblank::interrogate()

            rv$agent <- agent

            shiny::incProgress(0.5, detail = "Generating report...")
            report_html <- gt::as_raw_html(
              pointblank::get_agent_report(agent)
            )
            rv$validation_report <- report_html

            shiny::incProgress(0.3, detail = "Validation complete")
            shiny::showNotification(
              "Validation successful.",
              type = "message"
            )
          },
          error = function(e) {
            shiny::showNotification(
              paste("Validation error:", e$message),
              type = "error",
              duration = NULL
            )
          }
        )
      })
    })

    output$report_output <- shiny::renderUI({
      if (!is.null(rv$validation_report)) {
        shiny::HTML(rv$validation_report)
      } else if (!rv$download_successful && !is.null(input$uid_input)) {
        shiny::HTML(paste(
          "<p style='color: red; font-weight: bold;'>",
          "Data could not be downloaded.",
          "Check UID and your KoboToolbox setup.",
          "</p>"
        ))
      } else {
        shiny::HTML(
          "<p>Enter a valid UID and click 'Download Data' to begin.</p>"
        )
      }
    })

    shiny::reactive(rv$agent)
  })
}

#' Launch the Data Submission Validator Gadget
#'
#' Opens a miniUI-based Shiny gadget with modern styling for validating
#' KoboToolbox data submissions using pointblank.
#'
#' @return Launches the UI and returns validated data (or NULL if cancelled).
#' @export
kqc_ui <- function() {
  ui <- miniUI::miniPage(
    theme = bslib::bs_theme(version = 5),
    shinyjs::useShinyjs(),
    miniUI::gadgetTitleBar("Data Submission Validator"),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(NA, NA, 1),
        kqc_module_ui("kqc_validator_instance")
      )
    )
  )

  server <- function(input, output, session) {
    pb_agent_reactive <- kqc_module_server("kqc_validator_instance")

    shiny::observeEvent(input$cancel, {
      shiny::stopApp(NULL)
    })

    shiny::observeEvent(input$done, {
      if (!is.null(pb_agent_reactive())) {
        shiny::stopApp(pb_agent_reactive())
      } else {
        shiny::showNotification(
          "No validated data available. Please validate before proceeding.",
          type = "warning",
          duration = 5
        )
        shiny::stopApp(NULL)
      }
    })
  }

  shiny::runGadget(ui, server)
}
