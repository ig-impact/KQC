if (!require("httr2", quietly = TRUE)) {
  stop("Package 'httr2' needed for this script. Please install it.")
}

if (!require("readxl", quietly = TRUE)) {
  stop("Package 'readxl' needed for this script. Please install it.")
}

tmp_file <- tempfile(fileext = ".xlsx")

httr2::request(
  "https://repository.impact-initiatives.org/document/impact/efc7b590/REACH_oPt_MSNA-Dataset_OPT2101_16082021.xlsx"
) |>
  httr2::req_user_agent(string = "KQC") |>
  httr2::req_perform(path = tmp_file)

msna_opt_HH <- readxl::read_excel(tmp_file, sheet = "HH_data")
names(msna_opt_HH)[names(msna_opt_HH) == "X_uuid"] <- "_uuid"

msna_opt_Ind <- readxl::read_excel(tmp_file, sheet = "Ind_data")
names(msna_opt_Ind)[names(msna_opt_Ind) == "X_uuid"] <- "_uuid"

msna_opt_cl_HH <- readxl::read_excel(tmp_file, sheet = "cleaning_log_hh")
names(msna_opt_cl_HH)[names(msna_opt_cl_HH) == "X_uuid"] <- "_uuid"

msna_opt_dl_HH <- readxl::read_excel(tmp_file, sheet = "deletion_log")
names(msna_opt_dl_HH)[names(msna_opt_dl_HH) == "X_uuid"] <- "_uuid"

usethis::use_data(msna_opt_HH, overwrite = TRUE)
usethis::use_data(msna_opt_Ind, overwrite = TRUE)
usethis::use_data(msna_opt_cl_HH, overwrite = TRUE)
usethis::use_data(msna_opt_dl_HH, overwrite = TRUE)
