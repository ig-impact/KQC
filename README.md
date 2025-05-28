
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

msna_opt_HH[1:5, 1:4] |>
  gt()
```

<div id="xcwbmdmjgn" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xcwbmdmjgn table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#xcwbmdmjgn thead, #xcwbmdmjgn tbody, #xcwbmdmjgn tfoot, #xcwbmdmjgn tr, #xcwbmdmjgn td, #xcwbmdmjgn th {
  border-style: none;
}
&#10;#xcwbmdmjgn p {
  margin: 0;
  padding: 0;
}
&#10;#xcwbmdmjgn .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#xcwbmdmjgn .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#xcwbmdmjgn .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#xcwbmdmjgn .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#xcwbmdmjgn .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#xcwbmdmjgn .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#xcwbmdmjgn .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#xcwbmdmjgn .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#xcwbmdmjgn .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#xcwbmdmjgn .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#xcwbmdmjgn .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#xcwbmdmjgn .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#xcwbmdmjgn .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#xcwbmdmjgn .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#xcwbmdmjgn .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcwbmdmjgn .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#xcwbmdmjgn .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#xcwbmdmjgn .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#xcwbmdmjgn .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcwbmdmjgn .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#xcwbmdmjgn .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcwbmdmjgn .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#xcwbmdmjgn .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcwbmdmjgn .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xcwbmdmjgn .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcwbmdmjgn .gt_left {
  text-align: left;
}
&#10;#xcwbmdmjgn .gt_center {
  text-align: center;
}
&#10;#xcwbmdmjgn .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#xcwbmdmjgn .gt_font_normal {
  font-weight: normal;
}
&#10;#xcwbmdmjgn .gt_font_bold {
  font-weight: bold;
}
&#10;#xcwbmdmjgn .gt_font_italic {
  font-style: italic;
}
&#10;#xcwbmdmjgn .gt_super {
  font-size: 65%;
}
&#10;#xcwbmdmjgn .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#xcwbmdmjgn .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#xcwbmdmjgn .gt_indent_1 {
  text-indent: 5px;
}
&#10;#xcwbmdmjgn .gt_indent_2 {
  text-indent: 10px;
}
&#10;#xcwbmdmjgn .gt_indent_3 {
  text-indent: 15px;
}
&#10;#xcwbmdmjgn .gt_indent_4 {
  text-indent: 20px;
}
&#10;#xcwbmdmjgn .gt_indent_5 {
  text-indent: 25px;
}
&#10;#xcwbmdmjgn .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#xcwbmdmjgn div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="_uuid">_uuid</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="region">region</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="locality_code">locality_code</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="locality_gaza">locality_gaza</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="_uuid" class="gt_row gt_left">1bfc7e07-bf5b-4a60-8096-9ba938a7008d</td>
<td headers="region" class="gt_row gt_left">gaza</td>
<td headers="locality_code" class="gt_row gt_right">703430</td>
<td headers="locality_gaza" class="gt_row gt_left">abasan_jadida</td></tr>
    <tr><td headers="_uuid" class="gt_row gt_left">1d149c73-1849-4f19-acfb-34e85063c2b2</td>
<td headers="region" class="gt_row gt_left">gaza</td>
<td headers="locality_code" class="gt_row gt_right">703430</td>
<td headers="locality_gaza" class="gt_row gt_left">abasan_jadida</td></tr>
    <tr><td headers="_uuid" class="gt_row gt_left">22b39a47-559f-4dbd-b5b7-854e9caed3e1</td>
<td headers="region" class="gt_row gt_left">gaza</td>
<td headers="locality_code" class="gt_row gt_right">703430</td>
<td headers="locality_gaza" class="gt_row gt_left">abasan_jadida</td></tr>
    <tr><td headers="_uuid" class="gt_row gt_left">289f63c3-ca8b-4aee-a5d4-85c7ec968963</td>
<td headers="region" class="gt_row gt_left">gaza</td>
<td headers="locality_code" class="gt_row gt_right">703430</td>
<td headers="locality_gaza" class="gt_row gt_left">abasan_jadida</td></tr>
    <tr><td headers="_uuid" class="gt_row gt_left">2c895107-7b72-4a85-87e0-246e46ea1d2a</td>
<td headers="region" class="gt_row gt_left">gaza</td>
<td headers="locality_code" class="gt_row gt_right">703430</td>
<td headers="locality_gaza" class="gt_row gt_left">abasan_jadida</td></tr>
  </tbody>
  &#10;  
</table>
</div>

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
