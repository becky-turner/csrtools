impute_missing_tp <- function(data, impute_cols, sample_size = "n_in_arm") {
  
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
