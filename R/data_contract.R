# Read and minimally validate a YAML data contract.

read_data_contract <- function(path) {
  if (!file.exists(path)) {
    stop("Contract file not found: ", path)
  }
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Install the 'yaml' package before reading a contract.")
  }

  contract <- yaml::read_yaml(path)

  required_sections <- c("dataset", "columns")
  missing_sections <- setdiff(required_sections, names(contract))
  if (length(missing_sections) > 0) {
    stop(
      "Contract is missing required section(s): ",
      paste(missing_sections, collapse = ", ")
    )
  }
  if (!is.list(contract$columns) || length(contract$columns) == 0) {
    stop("The contract must define at least one column.")
  }

  contract
}

contract_summary <- function(contract) {
  data.frame(
    column = names(contract$columns),
    type = vapply(
      contract$columns,
      function(x) x$type %||% NA_character_,
      character(1)
    ),
    required = vapply(
      contract$columns,
      function(x) isTRUE(x$required),
      logical(1)
    ),
    nullable = vapply(
      contract$columns,
      function(x) isTRUE(x$nullable),
      logical(1)
    ),
    stringsAsFactors = FALSE
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
