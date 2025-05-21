#' Identify a UUID column
#'
#' @inheritParams pointblank::serially
#'
#' @return The name of the first UUID column found, or `NA_character_` if none
#' are found.
#' @description This function looks for a UUID column in a data frame by
#' checking for common names that UUID columns might have, such as `_uuid`,
#' `uuid`, or `X_uuid`.
#'
#' @details The function uses the `fmatch` function to find the first match
#' among the potential UUID column names. If no match is found, it returns
#' `NA_character_`.
#'
#' @examples
#' df <- data.frame(
#'   `_uuid` = c(
#'     "123e4567-e89b-12d3-a456-426614174000",
#'     "123e4567-e89b-12d3-a456-426614174001"
#'   ),
#'   value = c(1, 2)
#' )
#'
#' identify_uuid_column(df)
#' @export
identify_uuid_column <- function(x) {
  potential_uuid_column_names <- c("_uuid", "uuid", "X_uuid")
  match_pos <- collapse::fmatch(potential_uuid_column_names, names(x))
  first_match <- which(!is.na(match_pos))[1]

  if (is.na(first_match)) {
    NA_character_
  } else {
    potential_uuid_column_names[first_match]
  }
}

#' Check for uuid validity
#'
#' @inheritParams pointblank::serially
#' @param  ... Unused for now, kept for future extensions
#'
#' @inherit pointblank::serially return
#' @export
check_valid_uuid <- function(x, ...) {
  uuid_col <- identify_uuid_column(x)
  x |>
    pointblank::serially(
      ~ pointblank::col_exists(., uuid_col),
      ~ pointblank::rows_distinct(., columns = uuid_col),
      ~ pointblank::col_vals_not_null(., uuid_col)
    )
}
