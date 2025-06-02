# --- Shiny Module for Data Submission Validation ---

#' UI for the Data Quality Control Module
#'
#' @param id character. A unique ID for the module instance.
#' @return A Shiny UI tag list.
#' @importFrom shiny textInput actionButton icon uiOutput
#' @importFrom htmltools div
#' @importFrom shinyjs useShinyjs
kqc_module_ui <- function(id) {
  ns <- shiny::NS(id) # Namespace function

  htmltools::tagList(
    shinyjs::useShinyjs(), # Initialize shinyjs for enable/disable

    # Input field for the UID
    shiny::textInput(
      ns("uid_input"),
      "Enter Submission UID:",
      value = "au3c9H4TvJjepgEAzEzk2j", # Placeholder for a real UID
      placeholder = "e.g., au3c9H4TvJjepgEAzEzk2j"
    ),
    # Container for action buttons
    htmltools::div(
      style = "display: flex; gap: 10px; margin-bottom: 15px;",
      # Button to initiate data download
      shiny::actionButton(
        ns("download_btn"),
        "Download Data",
        icon = shiny::icon("download"),
        class = "btn-primary"
      ),
      # Button to initiate data validation (initially disabled)
      shiny::actionButton(
        ns("validate_btn"),
        "Validate Data",
        icon = shiny::icon("check-circle"),
        class = "btn-info"
      )
    ),
    # Output area for displaying the pointblank report
    shiny::uiOutput(ns("report_output"))
  )
}

#' Server logic for the Data Quality Control Module
#'
#' @param id character. A unique ID for the module instance.
#' @return A reactive expression that returns the pointblank agent object.
#' @importFrom shiny reactiveValues observeEvent req withProgress incProgress
#' @importFrom shiny showNotification renderUI HTML
#' @importFrom shinyjs disable enable
#' @importFrom robotoolbox kobo_setup kobo_data
#' @importFrom pointblank create_agent col_exists col_vals_gt col_vals_lt
#' @importFrom pointblank col_vals_not_null col_vals_in_set interrogate
#' @importFrom pointblank action_levels get_agent_report
#' @importFrom gt as_raw_html
kqc_module_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    rv <- shiny::reactiveValues(
      downloaded_data = NULL,
      download_successful = FALSE,
      validation_report = NULL,
      agent = NULL
    )

    # --- Initial Setup ---
    shiny::observeEvent(
      NULL,
      {
        shinyjs::disable("validate_btn")
      },
      once = TRUE
    )

    # --- Event Handler for Download Button ---
    shiny::observeEvent(input$download_btn, {
      shiny::req(input$uid_input)

      rv$download_successful <- FALSE
      rv$downloaded_data <- NULL
      rv$validation_report <- NULL
      shinyjs::disable("validate_btn")

      shiny::withProgress(message = "Downloading data...", value = 0, {
        shiny::incProgress(
          0.2,
          detail = paste("Fetching submissions for UID:", input$uid_input)
        )
        tryCatch(
          {
            robotoolbox::kobo_setup()

            data <- robotoolbox::kobo_data(input$uid_input)
            rv$downloaded_data <- data
            rv$download_successful <- TRUE
            shiny::incProgress(0.8, detail = "Download complete!")
            shiny::showNotification(
              "Data downloaded successfully!",
              type = "message",
              duration = 3
            )
          },
          error = function(e) {
            shiny::showNotification(
              paste(
                "Download failed:",
                e$message,
                "\nEnsure KOBOTOOLBOX_URL and KOBOTOOLBOX_TOKEN are set in .Renviron." # nolint line_length_linter
              ),
              type = "error",
              duration = NULL
            )
            rv$download_successful <- FALSE
          }
        )
      })

      if (rv$download_successful) {
        shinyjs::enable("validate_btn")
      }
    })

    # --- Event Handler for Validate Button ---
    shiny::observeEvent(input$validate_btn, {
      shiny::req(rv$downloaded_data)

      rv$validation_report <- NULL # Clear any previous validation report

      shiny::withProgress(message = "Validating data...", value = 0, {
        shiny::incProgress(0.2, detail = "Running pointblank agent...")
        tryCatch(
          {
            # Create and interrogate the pointblank agent
            agent <- pointblank::create_agent(
              tbl = rv$downloaded_data,
              label = "Data Submission Validation Report"
            ) |>
              pointblank::col_exists(
                columns = c("start", "end", "audit")
              ) |>
              pointblank::col_is_date(
                columns = "today"
              ) |>
              pointblank::col_vals_not_null(
                columns = "_uuid"
              ) |>
              pointblank::interrogate()

            rv$agent <- agent # Store the agent in reactive values
            shiny::incProgress(0.5, detail = "Generating report...")
            gt_report <- pointblank::get_agent_report(agent)
            report_html <- gt::as_raw_html(gt_report)
            rv$validation_report <- report_html
            shiny::incProgress(0.3, detail = "Validation complete!")
            shiny::showNotification(
              "Data validated successfully!",
              type = "message",
              duration = 3
            )
          },
          error = function(e) {
            shiny::showNotification(
              paste("Validation failed:", e$message),
              type = "error",
              duration = NULL
            )
          }
        )
      })
    })

    # --- Render the Validation Report ---
    output$report_output <- shiny::renderUI({
      if (!is.null(rv$validation_report)) {
        shiny::HTML(rv$validation_report)
      } else if (!is.null(rv$downloaded_data) && !rv$download_successful) {
        shiny::HTML(
          "<p style='color: red; font-weight: bold;'>Download failed. Please check the UID and your robotoolbox setup (environment variables for credentials) and try again.</p>" # nolint line_length_linter
        )
      } else {
        shiny::HTML(
          "<p>Enter a UID (e.g., 'aPzY8eN3wTfQ2uB1oC7jK') and click 'Download Data' to begin the process.</p>" # nolint line_length_linter
        )
      }
    })

    # Return the pointblank agent object
    return(shiny::reactive(rv$downloaded_data)) # nolint return_linter
  })
}


# --- Main Shiny Application (kqc_ui) ---

#' User Interface for Data Submission Validator
#'
#' This function launches a Shiny miniUI application for validating data
#' submissions using the KQC module.
#'
#' @return A Shiny miniUI application.
#' @export
#' @importFrom shiny shinyApp reactiveValues observeEvent req withProgress
#' @importFrom shiny incProgress showNotification
#' @importFrom shiny renderUI HTML textInput actionButton icon uiOutput fillCol
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel
#' @importFrom shinyjs useShinyjs disable enable
#' @importFrom htmltools div
#' @importFrom pointblank get_data_extracts
#' @importFrom robotoolbox kobo_setup
kqc_ui <- function() {
  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    miniUI::gadgetTitleBar("Data Submission Validator"),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(NA, NA, 1),
        kqc_module_ui("kqc_validator_instance") # Call the module UI
      )
    )
  )

  server <- function(input, output, session) {
    # Call the module server and capture the returned pointblank agent
    # The returned agent is a reactive expression, so access with ()
    pb_agent_reactive <- kqc_module_server("kqc_validator_instance")

    shiny::observeEvent(input$cancel, {
      shiny::stopApp(NULL)
    })

    shiny::observeEvent(input$done, {
      # Ensure agent is available before trying to get extracts
      if (!is.null(pb_agent_reactive())) {
        shiny::stopApp(pb_agent_reactive())
      } else {
        shiny::showNotification(
          "Validation did not pass all checks or no agent available. Cannot extract data.", # nolint line_length_linter
          type = "warning",
          duration = 5
        )
        shiny::stopApp(NULL)
      }
    })
  }

  shiny::runGadget(ui, server)
}
