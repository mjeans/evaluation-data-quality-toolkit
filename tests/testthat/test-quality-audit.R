candidate_roots <- c(".", "..", "../..")
project_root <- candidate_roots[
  file.exists(file.path(candidate_roots, "R", "data_contract.R"))
][1]
if (is.na(project_root)) {
  stop("Could not locate the project root for tests.")
}

source(file.path(project_root, "R", "data_contract.R"))
source(file.path(project_root, "R", "quality_audit.R"))

test_that("malformed dates become issues instead of aborting an audit", {
  bad <- c("not-a-date", "2025-02-30", "2026-1-01", "2026-01-01extra")
  expect_true(all(type_failures(bad, "date")))
  expect_false(any(type_failures(c("", NA_character_), "date")))
  expect_equal(parse_contract_date("2024-02-29"), as.Date("2024-02-29"))
  expect_true(is.na(parse_contract_date("2025-02-29")))
  contract <- list(columns = list(
    start = list(type = "date", required = TRUE, nullable = FALSE),
    end = list(type = "date", required = TRUE, nullable = TRUE)),
    rules = list(list(type = "date_order", name = "order",
                      earlier = "start", later = "end")))
  data <- data.frame(start = c("bad", "2026-01-02", ""),
                     end = c("also-bad", "2026-01-01", NA_character_))
  result <- run_quality_audit(data, contract)
  expect_equal(sum(result$n_failed[result$check == "type"]), 2)
  expect_equal(result$n_failed[result$check == "order"], 1)
  expect_equal(result$n_failed[result$check == "not_null"], 1)
  expect_equal(parse_contract_date("31/12/2026", "%d/%m/%Y"),
               as.Date("2026-12-31"))
})

test_that("a conforming dataset returns no issues", {
  contract <- read_data_contract(
    file.path(project_root, "config", "evaluation_records.yml")
  )
  clean <- data.frame(
    record_id = c("R001", "R002"),
    site_id = c("S01", "S02"),
    program = c("comparison", "intervention"),
    baseline_score = c(45, 52),
    outcome = c(50, 61),
    enrollment_date = c("2026-01-01", "2026-01-05"),
    followup_date = c("2026-06-01", "2026-06-05"),
    stringsAsFactors = FALSE
  )

  expect_equal(nrow(run_quality_audit(clean, contract)), 0)
})

test_that("duplicate, domain, range, and date errors are detected", {
  contract <- read_data_contract(
    file.path(project_root, "config", "evaluation_records.yml")
  )
  problem <- read.csv(
    file.path(project_root, "examples", "problem_records.csv"),
    na.strings = c("", "NA"),
    stringsAsFactors = FALSE
  )

  issues <- run_quality_audit(problem, contract)

  expect_setequal(
    issues$check,
    c(
      "unique",
      "not_null",
      "allowed_values",
      "maximum",
      "followup_not_before_enrollment"
    )
  )
  expect_equal(
    issues$n_failed[issues$check == "unique"],
    2
  )
})

test_that("required columns are enforced", {
  contract <- read_data_contract(
    file.path(project_root, "config", "evaluation_records.yml")
  )
  incomplete <- data.frame(record_id = "R001")

  issues <- run_quality_audit(incomplete, contract)

  expect_true(any(issues$check == "required_column"))
  expect_true(any(issues$column == "program"))
})
