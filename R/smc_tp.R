smc_tp <- function(data,
                   mean_from = "mean_baseline", sd_from = "sd_baseline", 
                   outcome_mean, outcome_sd,
                   sample_size = "n_in_arm",
                   study_id = "author_arm",
                   time_unit, time_point, 
                   hedges = FALSE, 
                   plot = FALSE, save_path = NULL,
                   heterogeneity = FALSE) { 
  
  # Subset rows with valid data
  ma_data <- data[!is.na(data[[outcome_mean]]) & !is.na(data[[outcome_sd]]), ]
  
  # Compute the standardized mean change and its variance
  if (hedges) {
    # Hedges' g correction
    ma_data$smc <- (ma_data[[outcome_mean]] - ma_data[[mean_from]]) / ma_data[[sd_from]]
    ma_data$correction_factor <- 1 - (3 / (4 * ma_data[[sample_size]] - 1))
    ma_data$smc <- ma_data$smc * ma_data$correction_factor  # Apply bias correction
    ma_data$smc_variance <- (1 / ma_data[[sample_size]]) + ma_data$smc^2
  } else {
    # Standard SMC calculation
    ma_data$smc <- (ma_data[[outcome_mean]] - ma_data[[mean_from]]) / ma_data[[sd_from]]
    ma_data$smc_variance <- (ma_data[[sample_size]] + ma_data$smc^2) / ma_data[[sample_size]]
  }
  
  # Run Meta-Analysis
  smc_result <- metafor::rma(yi = ma_data$smc, vi = ma_data$smc_variance, method = "REML", data = ma_data)
  
  # Generate and save plots if save_path is specified
  if (!is.null(save_path)) {
    file_name <- paste0(save_path, "_FFPlot_", time_point, "_", time_unit, ".jpeg")
    grDevices::jpeg(file = file_name, width = 16, height = 8, units = "in", res = 500)
    graphics::par(mfrow = c(1, 2))  # Set up two-panel layout
    plot_forest(smc_result, ma_data, study_id, time_point, time_unit)
    graphics::mtext("(a)", side = 3, line = 1, adj = 0, font = 2)
    plot_funnel(smc_result, time_point, time_unit)
    graphics::mtext("(b)", side = 3, line = 1, adj = 0, font = 2)
    grDevices::dev.off()
    return(save_path)
  }
  
  # If plot = TRUE but no save_path, capture plots and store them
  if (plot && is.null(save_path)) {
    graphics::par(mfrow = c(1, 2))  # Set up two-panel layout
    plot_forest(smc_result, ma_data, study_id, time_point, time_unit)
    graphics::mtext("(a)", side = 3, line = 1, adj = 0, font = 2)
    plot_funnel(smc_result, time_point, time_unit)
    graphics::mtext("(b)", side = 3, line = 1, adj = 0, font = 2)
  }
  
  # Calculate the sample size for this time point
  sample_size_col <- paste0(outcome_mean, "_sample")
  
  # Check if the sample size column exists before attempting to use it
  if (sample_size_col %in% colnames(ma_data)) {
    total_sample_size <- max(ma_data[[sample_size_col]], na.rm = TRUE)  # max gets 1 value
  } else {
    # Compute total sample size
    total_sample_size <- sum(ma_data[[sample_size]], na.rm = TRUE)
  }
  
  # Store results
  results <- data.frame("time_point" = time_point,
                        "total_sample" = total_sample_size,
                        "smc" = smc_result$beta, 
                        "lower_ci" = smc_result$ci.lb, 
                        "upper_ci" = smc_result$ci.ub)
  
  # If heterogeneity = TRUE, save heterogeneity statistics to results
  if (heterogeneity) {
    results$I2 <- smc_result$I2  # I-squared statistic
    results$Q <- smc_result$QE   # Cochran’s Q-statistic
    results$tau2 <- smc_result$tau2  # Tau-squared (between-study variance)
  }
  
  row.names(results) <- NULL
  return(results)
}
