# Render an aggregate Markdown report without row-level data.

write_quality_report <- function(
  issues,
  output_path,
  dataset_name,
  n_rows
) {
  dir.create(
    dirname(output_path),
    recursive = TRUE,
    showWarnings = FALSE
  )

  escape_markdown <- function(x) {
    gsub("|", "\\\\|", as.character(x), fixed = TRUE)
  }

  status <- if (nrow(issues) == 0) "PASS" else "REVIEW REQUIRED"
  lines <- c(
    paste0("# Data quality report: ", dataset_name),
    "",
    paste0("**Status:** ", status),
    "",
    paste0("**Records evaluated:** ", format(n_rows, big.mark = ",")),
    "",
    paste0("**Issue types identified:** ", nrow(issues)),
    "",
    "This report contains aggregate validation results only. It does not include row-level data.",
    ""
  )

  if (nrow(issues) == 0) {
    lines <- c(
      lines,
      "All configured checks passed.",
      ""
    )
  } else {
    lines <- c(
      lines,
      "## Findings",
      "",
      "| Check | Severity | Field | Records affected | Detail |",
      "|---|---|---|---:|---|"
    )

    report_rows <- apply(
      issues,
      1,
      function(x) {
        paste0(
          "| ", escape_markdown(x[["check"]]),
          " | ", escape_markdown(x[["severity"]]),
          " | ", escape_markdown(x[["column"]]),
          " | ", x[["n_failed"]],
          " | ", escape_markdown(x[["detail"]]),
          " |"
        )
      }
    )
    lines <- c(lines, report_rows, "")
  }

  lines <- c(
    lines,
    "## Recommended disposition",
    "",
    if (nrow(issues) == 0) {
      "The dataset is ready for the next pipeline stage, subject to project-specific review."
    } else {
      "Resolve or formally accept each finding before the dataset is used for inferential analysis."
    },
    ""
  )

  writeLines(lines, output_path, useBytes = TRUE)
  invisible(output_path)
}
