#' Impute missing data
#'
#' This function imputes missing values as proxies for calculations in specified columns by
#' replacing them with weighted means,based on the corresponding sample sizes.
#' It also creates new columns to store the sample sizes used for the imputation.
#'
#' @param data A data frame containing the input data to run imputations for missing data rows.
#' @param impute_cols A character vector specifying the column names in `data` to impute missing values for.
#' @param sample_size A string specifying the column name in `data` that contains the sample size values. Default is `"n_in_arm"`.
#'
#' @return A data frame with imputed values for the specified columns and new columns appended for each imputed column,
#' storing the total sample sizes used in the imputation process.
#' The new columns are named as `"{col}_sample"`.
#'
#' @details
#' - For each specified column, the function calculates a weighted mean of non-missing values, using the sample size as weights.
#' - Missing values are replaced with the weighted mean.
#' - A new column is created for each imputed column, storing the total sample size used for imputation.
#' - If there are no valid rows (all values are `NA`), the function assigns `NA` to the imputed values and sample size column.
#'
#' @examples
#' # Example dataset
#' data <- data.frame(
#'   week1 = c(NA, 5, 7, 8, NA),
#'   week2 = c(3, NA, 6, NA, 4),
#'   n_in_arm = c(10, 15, 20, 25, 30)
#' )
#'
#' impute_cols <- c("week1", "week2")
#'
#' # Run imputation
#' imputed_data <- impute_missing(data, impute_cols = impute_cols, sample_size = "n_in_arm")
#'
#' # View results
#' print(imputed_data)
#'
#' @export
#'
impute_missing <- function(data, impute_cols, sample_size = "n_in_arm") {

  # Create a copy of the data for modifications
  temp <- data

  # Loop over each column and replace NA means with a weighted mean
  for (col in impute_cols) {

    # Identify rows that have non-NA values in the column and sample size
    non_na_rows <- !is.na(temp[[col]]) & !is.na(temp[[sample_size]])

    # Compute total sample size before imputation
    total_sample_size <- ifelse(sum(non_na_rows) > 0,
                                sum(temp[[sample_size]][non_na_rows], na.rm = TRUE),
                                NA)  # If no valid rows, total_sample_size is NA

    # Define new column name for sample size
    timepoint_sample <- paste0(col, "_sample")

    # Initialize the new column
    temp[[timepoint_sample]] <- temp[[sample_size]]  # Start with NA

    # Assign total sample size to rows where data is not missing
    if (!is.na(total_sample_size)) {
      temp[[timepoint_sample]][!non_na_rows] <- total_sample_size
    }

    # Calculate the weighted mean based on non-NA rows and sample size
    if (sum(non_na_rows) > 0) {  # Ensure there are rows with valid data
      weighted_mean <- sum(temp[[col]][non_na_rows] * temp[[sample_size]][non_na_rows], na.rm = TRUE) /
        sum(temp[[sample_size]][non_na_rows], na.rm = TRUE)

      # Replace NA values with the calculated weighted mean
      imputed_rows <- is.na(temp[[col]])  # Identify rows to be imputed
      temp[[col]][imputed_rows] <- weighted_mean

      # Assign `NA` to the sample size column for rows where imputation was performed
      #temp[[timepoint_sample]][imputed_rows] <- 1
    }
  }

  return(temp)

}
