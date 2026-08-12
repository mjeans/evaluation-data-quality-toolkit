# Validate a data frame against a parsed contract.

empty_issue_table <- function() {
  data.frame(
    check = character(),
    severity = character(),
    column = character(),
    n_failed = integer(),
    detail = character(),
    stringsAsFactors = FALSE
  )
}

issue_row <- function(
  check,
  column,
  n_failed,
  detail,
  severity = "error"
) {
  data.frame(
    check = as.character(check),
    severity = as.character(severity),
    column = as.character(column),
    n_failed = as.integer(n_failed),
    detail = as.character(detail),
    stringsAsFactors = FALSE
  )
}

is_blank <- function(x) {
  is.na(x) | (is.character(x) & trimws(x) == "")
}

type_failures <- function(x, expected_type) {
  available <- !is_blank(x)
  if (!any(available)) {
    return(rep(FALSE, length(x)))
  }

  valid <- switch(
    expected_type,
    character = is.character(x),
    numeric = is.numeric(x),
    integer = {
      converted <- suppressWarnings(as.numeric(x))
      !is.na(converted) & converted == floor(converted)
    },
    logical = is.logical(x),
    date = {
      if (inherits(x, "Date")) {
        rep(TRUE, length(x))
      } else {
        !is.na(suppressWarnings(as.Date(as.character(x))))
      }
    },
    stop("Unsupported contract type: ", expected_type)
  )

  available & !valid
}

run_quality_audit <- function(data, contract) {
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame.")
  }
  if (!is.list(contract) || is.null(contract$columns)) {
    stop("'contract' must be a parsed data contract.")
  }

  issues <- list()
  add_issue <- function(x) {
    issues[[length(issues) + 1L]] <<- x
  }

  for (column_name in names(contract$columns)) {
    rules <- contract$columns[[column_name]]

    if (!column_name %in% names(data)) {
      if (isTRUE(rules$required)) {
        add_issue(
          issue_row(
            check = "required_column",
            column = column_name,
            n_failed = nrow(data),
            detail = "Required column is absent from the dataset."
          )
        )
      }
      next
    }

    values <- data[[column_name]]
    blank <- is_blank(values)

    if (!isTRUE(rules$nullable) && any(blank)) {
      add_issue(
        issue_row(
          check = "not_null",
          column = column_name,
          n_failed = sum(blank),
          detail = "Missing or blank value in a nonnullable field."
        )
      )
    }

    if (!is.null(rules$type)) {
      failed <- type_failures(values, rules$type)
      if (any(failed)) {
        add_issue(
          issue_row(
            check = "type",
            column = column_name,
            n_failed = sum(failed),
            detail = paste0("Value does not conform to type '", rules$type, "'.")
          )
        )
      }
    }

    if (!is.null(rules$allowed)) {
      failed <- !blank & !as.character(values) %in% as.character(rules$allowed)
      if (any(failed)) {
        add_issue(
          issue_row(
            check = "allowed_values",
            column = column_name,
            n_failed = sum(failed),
            detail = paste(
              "Value outside permitted set:",
              paste(rules$allowed, collapse = ", ")
            )
          )
        )
      }
    }

    numeric_values <- suppressWarnings(as.numeric(values))
    if (!is.null(rules$min)) {
      failed <- !blank & !is.na(numeric_values) & numeric_values < rules$min
      if (any(failed)) {
        add_issue(
          issue_row(
            check = "minimum",
            column = column_name,
            n_failed = sum(failed),
            detail = paste("Value is below", rules$min)
          )
        )
      }
    }
    if (!is.null(rules$max)) {
      failed <- !blank & !is.na(numeric_values) & numeric_values > rules$max
      if (any(failed)) {
        add_issue(
          issue_row(
            check = "maximum",
            column = column_name,
            n_failed = sum(failed),
            detail = paste("Value is above", rules$max)
          )
        )
      }
    }

    if (isTRUE(rules$unique)) {
      duplicate <- !blank & (
        duplicated(values) |
          duplicated(values, fromLast = TRUE)
      )
      if (any(duplicate)) {
        add_issue(
          issue_row(
            check = "unique",
            column = column_name,
            n_failed = sum(duplicate),
            detail = "Duplicate value in a unique field."
          )
        )
      }
    }
  }

  cross_rules <- contract$rules %||% list()
  for (rule in cross_rules) {
    if (identical(rule$type, "date_order")) {
      needed <- c(rule$earlier, rule$later)
      if (!all(needed %in% names(data))) {
        next
      }

      earlier <- suppressWarnings(as.Date(as.character(data[[rule$earlier]])))
      later <- suppressWarnings(as.Date(as.character(data[[rule$later]])))
      failed <- !is.na(earlier) & !is.na(later) & later < earlier

      if (any(failed)) {
        add_issue(
          issue_row(
            check = rule$name,
            column = paste(needed, collapse = " -> "),
            n_failed = sum(failed),
            detail = paste(rule$later, "occurs before", rule$earlier)
          )
        )
      }
    }
  }

  if (length(issues) == 0) {
    return(empty_issue_table())
  }

  result <- do.call(rbind, issues)
  rownames(result) <- NULL
  result
}
