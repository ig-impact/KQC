#' Check for uuid validity
#'
#' `r lifecycle::badge("experimental")`
#' @inheritParams pointblank::serially
#' @param  ... Unused for now, kept for future extensions
#'
#' @inherit pointblank::serially return
#' @export
check_valid_uuid <- function(x, ...) {
  # NOTE: Assumes that the uuid column is named "_uuid"
  pointblank::serially(
    x,
    ~ test_col_exists(., columns = "_uuid"),
    ~ test_rows_distinct(., columns = "_uuid"),
    ~ test_col_vals_not_null(., columns = "_uuid"),
  )
}
