# Data quality report: evaluation_records

**Status:** REVIEW REQUIRED

**Records evaluated:** 4

**Issue types identified:** 5

This report contains aggregate validation results only. It does not include row-level data.

## Findings

| Check | Severity | Field | Records affected | Detail |
|---|---|---|---:|---|
| unique | error | record_id | 2 | Duplicate value in a unique field. |
| not_null | error | site_id | 1 | Missing or blank value in a nonnullable field. |
| allowed_values | error | program | 1 | Value outside permitted set: comparison, intervention |
| maximum | error | baseline_score | 1 | Value is above 100 |
| followup_not_before_enrollment | error | enrollment_date -> followup_date | 1 | followup_date occurs before enrollment_date |

## Recommended disposition

Resolve or formally accept each finding before the dataset is used for inferential analysis.
