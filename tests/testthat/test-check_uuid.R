test_that("check_uuid works", {
  testthat::expect_no_error(
    check_valid_uuid(msna_opt_HH)
  )
  testthat::expect_no_error(
    suppressMessages(
      check_valid_uuid(pointblank::create_agent(msna_opt_HH)) |>
        pointblank::interrogate()
    )
  )

  testthat::expect_error(
    check_valid_uuid(cleaningtools::cleaningtools_clean_data)
  )

  # NOTE: must clarify this test is checking for integration
  # not whether the check fails
  testthat::expect_no_error(
    suppressMessages(pointblank::interrogate(
      check_valid_uuid(
        pointblank::create_agent(
          cleaningtools::cleaningtools_clean_data
        )
      )
    ))
  )
})
