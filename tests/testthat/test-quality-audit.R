source(
  testthat::test_path("..", "..", "R", "data_contract.R")
)
source(
  testthat::test_path("..", "..", "R", "quality_audit.R")
)

test_that("a conforming dataset returns no issues", {
  contract <- read_data_contract(
    testthat::test_path(
      "..",
      "..",
      "config",
      "evaluation_records.yml"
    )
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
    testthat::test_path(
      "..",
      "..",
      "config",
      "evaluation_records.yml"
    )
  )
  problem <- read.csv(
    testthat::test_path(
      "..",
      "..",
      "examples",
      "problem_records.csv"
    ),
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
    testthat::test_path(
      "..",
      "..",
      "config",
      "evaluation_records.yml"
    )
  )
  incomplete <- data.frame(record_id = "R001")

  issues <- run_quality_audit(incomplete, contract)

  expect_true(any(issues$check == "required_column"))
  expect_true(any(issues$column == "program"))
})
