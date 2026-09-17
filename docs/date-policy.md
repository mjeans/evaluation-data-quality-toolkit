# Strict dates and reviewable correction

Date fields declare `format: "%Y-%m-%d"` in the YAML contract. Parsing uses that format explicitly, then round-trips the value to reject impossible dates, ambiguous representations, trailing text, and non-zero-padded values. Nullable blanks remain missing; the nullability rule decides whether they are issues. Cross-field ordering uses the same parser and only compares valid dates.

The test suite covers invalid first values, all-invalid columns, invalid calendar dates, blanks, trailing characters, strict padding, and a declared alternate format. A malformed first record now returns an issue rather than aborting the audit.

Run `Rscript examples/date_resolution.R` for a one-record synthetic example:

1. A malformed enrollment date produces a [review-required report](../outputs/date-failure-report.md).
2. The known fixture reference is restored explicitly, representing source-owner confirmation rather than an automatic guess.
3. Rerunning the exact contract produces a [passing report](../outputs/date-corrected-report.md).

Passing means only that the configured checks found no issue. It does not establish substantive validity, provenance, or suitability for inference. Keep a real correction log with the source evidence, reviewer, and disposition.
