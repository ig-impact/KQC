
<!-- README.md is generated from README.Rmd. Please edit that file -->

# KQC

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of KQC like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## What does **KQC** do?

*KQC* (Kobo Quality Checks) is an R package-in-progress that will let
you:

1.  **Validate an external cleaning log** against Kobo raw data and the
    XLS-form.  
2.  **Apply** that log to generate a corrected ( “clean” ) dataset.  
3.  **Run a minimal QC battery** – duplicate IDs, duplicate rows, soft
    duplicates and numeric outliers (with an exemption mechanism for
    values already justified in the cleaning log).  
4.  **Export** the clean, PII-scrubbed data (XLSX/RDS) and – later – an
    HTML audit report, ready for download or hand-off.

A Shiny interface is planned so that non-coder colleagues can paste an
asset-ID, attach a cleaning-log XLSX and get the same outputs with one
click.

------------------------------------------------------------------------

## Quick Start

``` r
library(KQC)
library(pointblank)
library(gt)

msna_opt_HH[1:5, 1:4]
#> # A tibble: 5 × 4
#>   `_uuid`                              region locality_code locality_gaza
#>   <chr>                                <chr>          <dbl> <chr>        
#> 1 1bfc7e07-bf5b-4a60-8096-9ba938a7008d gaza          703430 abasan_jadida
#> 2 1d149c73-1849-4f19-acfb-34e85063c2b2 gaza          703430 abasan_jadida
#> 3 22b39a47-559f-4dbd-b5b7-854e9caed3e1 gaza          703430 abasan_jadida
#> 4 289f63c3-ca8b-4aee-a5d4-85c7ec968963 gaza          703430 abasan_jadida
#> 5 2c895107-7b72-4a85-87e0-246e46ea1d2a gaza          703430 abasan_jadida
```

``` r
agent <- create_agent(tbl = msna_opt_HH) |>
  col_is_uuid()
```

<div class="figure" style="text-align: center">

<img src="man/figures/gt_table.png" alt="A pointblank agent with a UUID column check." width="100%" />
<p class="caption">
A pointblank agent with a UUID column check.
</p>

</div>

After running the interrogation, the agent will have a `status` column
that indicates whether the checks passed or failed. You can also use the
`get_agent_x_list()` function to extract the report object and save it
as an HTML table.

<div class="figure" style="text-align: center">

<img src="man/figures/gt_table_int.png" alt="A pointblank agent after interrogation" width="100%" />
<p class="caption">
A pointblank agent after interrogation
</p>

</div>

    #> 
    #> 1bfc7e07-bf5b-4a60-8096-9ba938a7008d 1d149c73-1849-4f19-acfb-34e85063c2b2 
    #>                                    1                                    2 
    #> 22b39a47-559f-4dbd-b5b7-854e9caed3e1 289f63c3-ca8b-4aee-a5d4-85c7ec968963 
    #>                                    1                                    1 
    #> 3745bc58-6075-436b-9a4c-37171575e7f9 3ed67c1c-06c0-4145-8ab9-5e1a2a9204cd 
    #>                                    2                                    1 
    #>                                 <NA> 
    #>                                    2
