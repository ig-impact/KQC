test_that("col_is_uuid passes with valid UUID column", {
  df <- data.frame(`_uuid` = c("a", "b", "c"), check.names = FALSE)
  expect_silent(col_is_uuid(df))
})

test_that("col_is_uuid fails when `_uuid` column is missing", {
  df <- data.frame(other_col = 1:3)
  expect_error(col_is_uuid(df))
})

test_that("col_is_uuid fails when all `_uuid` values are NA", {
  df <- data.frame(`_uuid` = c(NA, NA, NA), check.names = FALSE)
  expect_error(col_is_uuid(df))
})

test_that("col_is_uuid fails when `_uuid` contains duplicates", {
  df <- data.frame(`_uuid` = c("a", "b", "a"), check.names = FALSE)
  expect_error(col_is_uuid(df))
})

test_that("col_is_uuid fails with both duplicates and NA values", {
  df <- data.frame(`_uuid` = c("a", "b", NA, "a"), check.names = FALSE)
  expect_error(col_is_uuid(df))
})

test_that("create_agent + col_is_uuid passes on valid data", {
  df <- data.frame(`_uuid` = c("a", "b", "c"), check.names = FALSE)
  expect_silent({
    agent <- pointblank::create_agent(tbl = df) |>
      col_is_uuid() |>
      pointblank::interrogate(
        progress = FALSE
      )
  })
  # The number of passed validations should be 3 since it's the number of checks
  # performed within `serially`
  expect_equal(agent$validation_set$n_passed, 3)
})
