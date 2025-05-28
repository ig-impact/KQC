#' Check for uuid validity
#'
#' `r lifecycle::badge("experimental")`
#' @inheritParams pointblank::serially
#' @param  ... Unused for now, kept for future extensions
#'
#' @note This function assumes that the uuid column is named "_uuid".
#' @inherit pointblank::serially return
#' @export
col_is_uuid <- function(x, ...) {
  pointblank::serially(
    x,
    ~ test_col_exists(., columns = "_uuid"),
    ~ test_rows_distinct(., columns = "_uuid"),
    ~ col_vals_not_null(., columns = "_uuid", label = "inside"),
    label = "UUID validity check",
    brief = "Check that the `_uuid` column contains valid UUIDs.",
    step_id = "col_vals_uuid",
  )
}
