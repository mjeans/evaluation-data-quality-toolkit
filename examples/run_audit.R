# Run the toolkit against the intentionally flawed example extract.

suppressPackageStartupMessages({
  library(readr)
})

source("R/data_contract.R")
source("R/quality_audit.R")
source("R/report.R")

contract <- read_data_contract("config/evaluation_records.yml")
records <- read_csv(
  "examples/problem_records.csv",
  show_col_types = FALSE
)

issues <- run_quality_audit(records, contract)

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write_csv(issues, "outputs/quality-issues.csv")
write_quality_report(
  issues = issues,
  output_path = "outputs/quality-report.md",
  dataset_name = contract$dataset,
  n_rows = nrow(records)
)

message(
  "Audit completed with ",
  nrow(issues),
  " issue type(s)."
)
print(issues)
