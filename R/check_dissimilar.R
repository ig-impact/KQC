#' Check for dissimilar rows
#'
#' `r lifecycle::badge("experimental")`
#' @inheritParams pointblank::serially
#' @param  tool kobo survey
#' @param  threshold minimum number of dissimilar columns between rows
#' @param  ... Unused for now, kept for future extensions
#'
#' @inherit pointblank::serially return
#' @export
check_dissimilar <- function(x, tool, threshold = 7, ...) {
  x |>
    pointblank::col_vals_null(
      columns = "uuid",
      preconditions = function(x) {
        cleaningtools::check_soft_duplicates(
          dataset = x,
          kobo_survey = tool,
          uuid_column = "_uuid", # NOTE: Assuming the uuid column is always named "_uuid"
          threshold = 7
        )$soft_duplicate_log
      }
    )
}
