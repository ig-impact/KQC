# --- Mock Functions for robotoolbox and pointblank ---
# These functions simulate the behavior of robotoolbox and pointblank
# You will need to replace these with your actual package calls.

#' Mock function to simulate data submission download from robotoolbox
#'
#' This function simulates a network delay and returns a dummy data frame
#' if a specific UID is provided. Otherwise, it throws an error.
#'
#' @keywords internal
#' @param uid A character string representing the unique identifier.
#' @return A data frame if `uid` is "valid_uid", otherwise throws an error.
download_submissions_mock <- function(uid) {
  message("Simulating robotoolbox download for UID: ", uid)
  Sys.sleep(2) # Simulate network delay for download

  if (uid == "valid_uid") {
    # Return a dummy data frame for demonstration
    data.frame(
      id = 1:5,
      submission_time = Sys.time() - c(5, 4, 3, 2, 1) * 86400,
      value1 = c(10, 20, 30, 40, NA), # NA included to demonstrate NA checks
      value2 = c("A", "B", "C", "D", "E"),
      stringsAsFactors = FALSE
    )
  } else {
    stop(
      "Invalid UID or download failed. Please use 'valid_uid' for demonstration." # nolint line_length_linter
    )
  }
}

#' Mock function to simulate pointblank agent creation and interrogation
#'
#' This function creates a simple pointblank agent with predefined checks
#' and interrogates the provided data.
#'
#' @keywords internal
#' @param data A data frame to be interrogated by the pointblank agent.
#' @return A pointblank agent object after interrogation.
#' @importFrom pointblank create_agent col_exists col_vals_gt col_vals_lt
#' @importFrom pointblank col_vals_not_null col_vals_in_set
#' @importFrom pointblank interrogate action_levels get_agent_report
#' @importFrom gt as_raw_html
create_pb_agent_mock <- function(data) {
  message("Simulating pointblank agent interrogation.")
  Sys.sleep(3) # Simulate time taken for interrogation

  if (is.null(data) || !is.data.frame(data)) {
    stop("No valid data provided for validation.")
  }

  agent <- pointblank::create_agent(
    tbl = data,
    label = "Data Submission Validation Report"
  ) |>
    pointblank::col_exists(
      columns = c("id", "submission_time", "value1", "value2")
    ) |>
    pointblank::col_vals_gt(
      columns = "value1",
      value = 0,
      na_pass = TRUE
    ) |>
    pointblank::col_vals_lt(
      columns = "value1",
      value = 100,
      na_pass = TRUE,
      actions = pointblank::action_levels(
        warn_at = 0.5,
        stop_at = 0.75
      )
    ) |>
    pointblank::col_vals_not_null(
      columns = "value2"
    ) |>
    pointblank::col_vals_in_set(
      columns = "value2",
      set = c("A", "B", "C", "D", "E", "F")
    ) |>
    pointblank::interrogate()

  agent
}

#' User Interface for Data Submission Validator
#'
#' This function launches a Shiny miniUI application for validating data
#' submissions.
#'
#' @return A Shiny miniUI application for validating data submissions.
#' @export
#' @importFrom shiny shinyApp reactiveValues observeEvent req withProgress
#' @importFrom shiny incProgress showNotification
#' @importFrom shiny showNotification renderUI HTML textInput actionButton
#' @importFrom shiny icon uiOutput fillCol
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel
#' @importFrom shinyjs useShinyjs disable enable
#' @importFrom htmltools div
kqc_ui <- function() {
  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),

    # Title bar for the miniUI application
    miniUI::gadgetTitleBar("Data Submission Validator"),

    # Main content panel
    miniUI::miniContentPanel(
      # Use fillCol for a flexible column layout
      shiny::fillCol(
        flex = c(NA, NA, 1),
        # Input field for the UID
        shiny::textInput(
          "uid_input",
          "Enter Submission UID:",
          value = "valid_uid",
          placeholder = "e.g., valid_uid"
        ),
        # Container for action buttons
        htmltools::div(
          style = "display: flex; gap: 10px; margin-bottom: 15px;",
          # Button to initiate data download
          shiny::actionButton(
            "download_btn",
            "Download Data",
            icon = shiny::icon("download"),
            class = "btn-primary"
          ), # Add a primary button style
          # Button to initiate data validation (initially disabled)
          shiny::actionButton(
            "validate_btn",
            "Validate Data",
            icon = shiny::icon("check-circle"),
            class = "btn-info"
          ) # Add an info button style
        ),
        # Output area for displaying the pointblank report
        shiny::uiOutput("report_output")
      )
    )
  )

  server <- function(input, output, session) {
    rv <- shiny::reactiveValues(
      downloaded_data = NULL,
      download_successful = FALSE,
      validation_report = NULL
    )

    # --- Initial Setup ---
    # Disable the validate button when the app starts
    shiny::observeEvent(
      NULL,
      {
        # Use observeEvent(NULL, ...) with once = TRUE for initial setup
        shinyjs::disable("validate_btn")
      },
      once = TRUE
    )

    # --- Event Handler for Download Button ---
    shiny::observeEvent(input$download_btn, {
      shiny::req(input$uid_input)

      # Reset states before a new download attempt
      rv$download_successful <- FALSE
      rv$downloaded_data <- NULL
      rv$validation_report <- NULL
      shinyjs::disable("validate_btn") # Disable validate button during download

      # Show a progress spinner during the download process
      shiny::withProgress(message = "Downloading data...", value = 0, {
        shiny::incProgress(
          0.2,
          detail = paste("Fetching submissions for UID:", input$uid_input)
        )
        tryCatch(
          {
            # Call the mocked robotoolbox function to get data
            data <- download_submissions_mock(input$uid_input)
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
            # Handle download errors
            shiny::showNotification(
              paste("Download failed:", e$message),
              type = "error",
              duration = NULL
            )
            rv$download_successful <- FALSE
          }
        )
      })

      # Enable the validate button if the download was successful
      if (rv$download_successful) {
        shinyjs::enable("validate_btn")
      }
    })

    # --- Event Handler for Validate Button ---
    shiny::observeEvent(input$validate_btn, {
      shiny::req(rv$downloaded_data)

      rv$validation_report <- NULL # Clear any previous validation report

      # Show a progress spinner during the validation process
      shiny::withProgress(message = "Validating data...", value = 0, {
        shiny::incProgress(0.2, detail = "Running pointblank agent...")
        tryCatch(
          {
            # Call the mocked pointblank function to interrogate the data
            agent <- create_pb_agent_mock(rv$downloaded_data)
            shiny::incProgress(0.5, detail = "Generating report...")
            # Get the gt table from the agent report
            gt_report <- pointblank::get_agent_report(agent)
            # Convert the gt table to raw HTML for display
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
            # Handle validation errors
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
        # If a report exists, render it as HTML
        shiny::HTML(rv$validation_report)
      } else if (!is.null(rv$downloaded_data) && !rv$download_successful) {
        # Message if download failed
        shiny::HTML(
          "<p style='color: red; font-weight: bold;'>Download failed. Please check the UID and try again.</p>" # nolint line_length_linter
        )
      } else {
        # Initial instructional message
        shiny::HTML(
          "<p>Enter a UID (e.g., 'valid_uid') and click 'Download Data' to begin the process.</p>" # nolint line_length_linter
        )
      }
    })
  }

  shiny::shinyApp(ui, server)
}
