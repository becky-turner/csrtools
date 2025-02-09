pooled_smc_tp <- function(data, outcome_means, outcome_sds, 
                          baseline_mean, baseline_sd, sample_size,
                          time_points, time_unit, intervention = NULL, plot = TRUE) {
  # Use `::` to call package-specific functions
  meta_analysis_single <- function(data, outcome_mean, outcome_sd, time_point) {
    # Debugging: print column names being accessed
    print(paste("Processing:", outcome_mean, outcome_sd))
    
    # Ensure columns exist in the data
    if (!outcome_mean %in% colnames(data) || !outcome_sd %in% colnames(data)) {
      stop(paste("Column", outcome_mean, "or", outcome_sd, "not found in the data"))
    }
    
    # Filter for valid rows
    valid_data <- data %>%
      dplyr::filter(!is.na(rlang::sym(outcome_mean)) & !is.na(rlang::sym(outcome_sd)))
    
    if (nrow(valid_data) > 0) {
      valid_data <- valid_data %>%
        dplyr::mutate(
          smc = (rlang::sym(outcome_mean) - rlang::sym(baseline_mean)) / rlang::sym(baseline_sd),
          smc_variance = (rlang::sym(sample_size) + smc^2) / rlang::sym(sample_size)
        )
      
      res <- metafor::rma(yi = valid_data$smc, vi = valid_data$smc_variance, method = "REML", data = valid_data)
      return(data.frame(time_point = time_point, smc = res$b, lower_ci = res$ci.lb, upper_ci = res$ci.ub))
    } else {
      return(data.frame(time_point = time_point, smc = NA, lower_ci = NA, upper_ci = NA))
    }
  }
  
  # Run meta-analysis for each time point
  results_list <- lapply(seq_along(outcome_means), function(i) {
    meta_analysis_single(data, outcome_means[i], outcome_sds[i], time_points[i])
  })
  
  # Combine results into a data frame
  results <- do.call(rbind, results_list)
  results$time_point <- as.numeric(results$time_point)
  results$time_unit <- time_unit
  results$intervention <- intervention
  row.names(results) <- NULL
  
  plot_p <- NULL
  
  if (plot) { 
    # Use plot_pooled_smc_tp function
    plot_p <- plot_pooled_smc_tp(results, x = "time_point", y = "smc")
    print(plot_p)
  }
  
  return(results)
}
