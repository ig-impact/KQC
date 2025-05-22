#' Household-level data from the 2021 oPt MSNA
#'
#' This dataset contains household-level survey data from the 2021 Multi-Sector Needs Assessment (MSNA)
#' conducted in the occupied Palestinian territory (oPt). It includes socioeconomic indicators, access to services,
#' perceived needs, coping mechanisms, and household demographics.
#'
#' @source [IMPACT Initiatives Resource Centre](https://repository.impact-initiatives.org/document/impact/efc7b590/REACH_oPt_MSNA-Dataset_OPT2101_16082021.xlsx)
"msna_opt_HH"

#' Individual-level data from the 2021 oPt MSNA
#'
#' This dataset includes information on individuals within surveyed households. It allows disaggregation by age, gender,
#' and other demographic characteristics.
#'
#' @source See \code{\link{msna_opt_HH}}.
"msna_opt_Ind"

#' Cleaning log for household data from the 2021 oPt MSNA
#'
#' This dataset records all manual or scripted corrections applied to the household dataset. It follows a structured cleaning log format.
#'
#' @source See \code{\link{msna_opt_HH}}.
"msna_opt_cl_HH"

#' Deletion log for household records in the 2021 oPt MSNA
#'
#' This log identifies records removed from the dataset during data cleaning, typically due to quality issues or duplication.
#'
#' @source See \code{\link{msna_opt_HH}}.
"msna_opt_dl_HH"
