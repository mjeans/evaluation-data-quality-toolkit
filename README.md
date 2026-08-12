# Evaluation data-quality toolkit

A lightweight, reusable framework for validating evaluation and administrative datasets before analysis. The toolkit separates data expectations from the checking code through a human-readable YAML contract, then produces a structured issue table and a Markdown audit report.

The example records are synthetic. No client, participant, or organization data are included.

## What it checks

- required columns
- missing values in nonnullable fields
- expected data types
- permitted categorical values
- numeric ranges
- duplicate identifiers
- cross-field date logic
- reusable SQL checks for warehouse-side validation

## Why a data contract

A data contract makes analytic expectations reviewable before a model is run. Program staff can inspect the field definitions, data engineers can translate them upstream, and analysts can rerun the same checks whenever a new extract arrives.

The included contract defines one hypothetical evaluation-records table:

~~~yaml
dataset: evaluation_records
primary_key: record_id
columns:
  baseline_score:
    type: numeric
    required: true
    nullable: false
    min: 0
    max: 100
~~~

## Repository structure

~~~text
R/
  data_contract.R
  quality_audit.R
  report.R
config/
  evaluation_records.yml
examples/
  problem_records.csv
  run_audit.R
  example-quality-report.md
sql/
  duplicate-key-check.sql
  domain-and-range-checks.sql
  orphaned-foreign-keys.sql
tests/testthat/
  test-quality-audit.R
.github/workflows/
  validate-toolkit.yml
~~~

## Run the example

With R 4.4 or later:

~~~r
install.packages(c("readr", "testthat", "yaml"))

source("R/data_contract.R")
source("R/quality_audit.R")
source("R/report.R")
source("examples/run_audit.R")
~~~

The example intentionally contains a duplicate key, a missing site identifier, an invalid program value, an out-of-range baseline score, and a follow-up date before enrollment. The generated audit report makes each issue visible without exposing row-level personal information.

## Adapt it to another dataset

1. Copy and edit the YAML contract.
2. Add or remove cross-field rules.
3. Point `run_quality_audit()` to the new data frame and contract.
4. Add tests for organization-specific rules.
5. Run the checks in CI or before every scheduled analysis.

## Design choices

The core functions return ordinary data frames and use base R for validation. Only YAML parsing and example-file reading require packages. This keeps the logic inspectable and makes it easier to embed in an existing pipeline.

The SQL examples are intentionally straightforward and portable to AWS Athena/Trino-style warehouses. They demonstrate useful validation queries without implying advanced database engineering.

## Skills demonstrated

Data governance · validation rules · data contracts · automated testing · audit reporting · R · SQL · GitHub Actions

## License

MIT
