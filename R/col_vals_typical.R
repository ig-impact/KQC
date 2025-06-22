#' @importFrom pointblank create_agent interrogate col_vals_expr
#' @importFrom dplyr select all_of
#' @importFrom glue glue
#' @importFrom rlang enquo parse_expr `%||%`
NULL

#' Check for Outliers Using the Interquartile Range (IQR)
#'
#' `r lifecycle::badge("experimental")`
#'
#' @description
#' Determines if values in numeric columns are outliers based on the
#' interquartile range (IQR). A value is considered an outlier if it falls
#' outside the range defined by `[Q1 - k * IQR, Q3 + k * IQR]`.
#'
#' This function is modeled after the native `col_vals_*()` family of
#' validation functions and is designed to integrate seamlessly into a
#' `{pointblank}` agent pipeline.
#'
#' @inheritParams pointblank::col_vals_gt
#'
#' @param k A numeric multiplier for the IQR. A higher value of `k` creates
#'   a wider, more tolerant range for outlier detection. Defaults to `1.5`.
#'
#' @return For the validation function, the return value is either a
#'   `ptblank_agent` object or a table object (depending on whether an
#'   `agent` object or a table was passed to `x`).
#'
#' @family Custom Validation Functions
#'
#' @examples
#' \dontrun{
#' # Create a sample table with outliers
#' tbl <-
#'   dplyr::tibble(
#'     group = c("A", "A", "A", "B", "B", "B"),
#'     value = c(10, 12, 11, 50, 55, 200)
#'   )
#'
#' # Validate column `value` for outliers, checking each
#' # group in the `group` column separately
#' agent <-
#'   create_agent(tbl) %>%
#'   col_vals_iqr_outlier(
#'     columns = c(value),
#'     segments = c(group),
#'     actions = action_levels(stop_at = 1)
#'   ) %>%
#'   interrogate()
#'
#' agent
#' }
#'
#' @export
col_vals_typical <- function(x,
                             columns,
                             k = 1.5,
                             actions = NULL,
                             label = NULL,
                             brief = NULL,
                             ...) {
  if (pointblank:::is_a_table_object(x)) {
    secret_agent <-
      create_agent(x, label = "::QUIET::") %>%
      col_vals_iqr_outlier(
        columns = {{ columns }},
        k = k,
        actions = pointblank:::prime_actions(actions),
        label = label,
        brief = brief,
        ...
      ) %>%
      interrogate()

    return(x)
  }

  agent <- x

  vars <- rlang::enquo(columns)
  column_names <- pointblank:::resolve_columns(x = agent, var_expr = vars)

  tbl_subset <- dplyr::select(agent$tbl, dplyr::all_of(column_names))
  non_numeric <- names(tbl_subset)[!sapply(tbl_subset, is.numeric)]
  if (length(non_numeric) > 0) {
    stop(glue::glue(
      "All columns for this check must be numeric. Problematic columns: {paste(non_numeric, collapse = ', ')}"
    ), call. = FALSE)
  }

  for (col_name in column_names) {
    expr_string <- glue(
      "`{col_name}` >= (quantile(`{col_name}`, 0.25, na.rm = TRUE) - {k} * IQR(`{col_name}`, na.rm = TRUE)) & ",
      "`{col_name}` <= (quantile(`{col_name}`, 0.75, na.rm = TRUE) + {k} * IQR(`{col_name}`, na.rm = TRUE))"
    )
    validation_expr <- rlang::parse_expr(expr_string)

    step_brief <- brief %||% "Values in `{col_name}` must be within the IQR bounds ({k} * IQR)."
    step_brief <- glue::glue(step_brief, col_name = col_name, k = k)

    # Add a validation step by calling the generic `col_vals_expr`
    agent <-
      agent %>%
      col_vals_expr(
        expr = validation_expr,
        actions = actions,
        label = label,
        brief = step_brief,
        ...
      )
  }

  return(agent)
}
