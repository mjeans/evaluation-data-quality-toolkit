# A controlled synthetic correction; not an automatic repair policy.
source("R/data_contract.R")
source("R/quality_audit.R")
source("R/report.R")
contract <- read_data_contract("config/evaluation_records.yml")
record <- readr::read_csv("examples/problem_records.csv", show_col_types = FALSE)[1, ]
record$enrollment_date <- "not-a-date"
before <- run_quality_audit(record, contract)
stopifnot(any(before$check == "type"))
write_quality_report(before, "outputs/date-failure-report.md", "synthetic_date_before_review", 1)
# For this fixture only, the author-supplied reference is known. A real analyst
# must obtain source-owner confirmation, not guess the date.
record$enrollment_date <- "2026-01-02"
after <- run_quality_audit(record, contract)
stopifnot(nrow(after) == 0L)
write_quality_report(after, "outputs/date-corrected-report.md", "synthetic_date_after_review", 1)
writeLines(capture.output(sessionInfo()), "outputs/session-info.txt", useBytes = TRUE)
