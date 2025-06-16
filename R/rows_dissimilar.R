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
  dataset <- if ("ptblank_agent" %in% class(x)) x$tbl else x

  # TODO: Handle the rest of the parameters especially sm_sepearator
  soft_duplicates_log <- cleaningtools::check_soft_duplicates(
    dataset = dataset,
    kobo_survey = tool,
    uuid_column = "_uuid", # NOTE: this is assumed as the default
    threshold = threshold,
    ...
  )$soft_duplicate_log
  x |>
    pointblank::col_vals_null(
      columns = "uuid",
      preconditions = \(x) soft_duplicates_log,
      label = "Soft Duplicates",
      brief = "Check soft duplicates"
    )
}
