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
rows_dissimilar <- function(x, tool, threshold = 7, ...) {
  x |>
    pointblank::col_vals_null(
      columns = "uuid",
      preconditions = function(x) {
        cleaningtools::check_soft_duplicates(
          dataset = x,
          kobo_survey = tool,
          uuid_column = "_uuid",
          threshold = threshold,
          ...
        )$soft_duplicate_log
      },
      label = "Dissimilar Rows",
      brief = "Check for dissimilar rows based on soft duplicates"
    )
}
