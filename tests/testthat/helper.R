test_raw_data <- cleaningtools::cleaningtools_raw_data |>
  dplyr::rename(
    `_uuid` = "X_uuid"
  ) |>
  dplyr::relocate(`_uuid`)

test_survey <- cleaningtools::cleaningtools_survey
test_choices <- cleaningtools::cleaningtools_choices
