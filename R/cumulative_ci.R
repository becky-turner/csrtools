# Calculate CI corrections-----------------------
cumulative_ci <- function(data, csmc = "smc_cum", upper_ci = "upper_ci", lower_ci = "lower_ci", 
                          time_point = "time_point", n_boot = 1000, # bootstrap parameters
                          sample_size = "total_sample", # nct parameters
                          method) { 
  
  # Copy data to avoid modifying the original dataset
  temp <- data
  
  if (method == "fixed") {
    # Fixed-width CI method (additive variance approach)
    temp <- dplyr::mutate(temp,
                          lower_ci_fixed = rlang::sym(csmc) - ((rlang::sym(upper_ci) - rlang::sym(lower_ci)) / 2),
                          upper_ci_fixed = rlang::sym(csmc) + ((rlang::sym(upper_ci) - rlang::sym(lower_ci)) / 2))
  }
  
  if (method == "wald") {
    # Wald-based method (propagated cumulative variance approach)
    temp <- dplyr::mutate(temp,
                          var_cum = cumsum((rlang::sym(upper_ci) - rlang::sym(lower_ci))^2 / (2 * 1.96)^2),
                          lower_ci_wald = rlang::sym(csmc) - 1.96 * sqrt(var_cum),
                          upper_ci_wald = rlang::sym(csmc) + 1.96 * sqrt(var_cum))
  }
  
  if (method == "bootstrap") {
    # Bootstrap-based confidence intervals (cumulative bootstrap approach)
    bootstrap_smc <- function(data, indices) {
      # Resample data
      boot_data <- data[indices, ]
      
      # Compute cumulative SMC
      boot_data <- dplyr::mutate(dplyr::arrange(boot_data, rlang::sym(time_point)), 
                                 smc_cum = rlang::sym(csmc))
      
      return(boot_data$smc_cum)  # Return cumulative SMC values
    }
    
    # Run the bootstrap
    boot_results <- boot::boot(data = temp, statistic = bootstrap_smc, R = n_boot)
    
    # Convert bootstrap samples into a dataframe
    boot_samples <- as.data.frame(boot_results$t)
    
    # Compute confidence intervals using percentiles
    boot_ci <- apply(boot_samples, 2, function(x) quantile(x, probs = c(0.025, 0.975)))
    
    # Add bootstrapped confidence intervals to the dataset
    temp <- dplyr::mutate(temp,
                          lower_ci_bootstrap = boot_ci[1, ],  # 2.5th percentile
                          upper_ci_bootstrap = boot_ci[2, ]   # 97.5th percentile
    )
  }
  
  if (method == "nct") {
    # Non-central t-distribution method
    temp <- dplyr::mutate(temp,
                          var_smc = ((rlang::sym(upper_ci) - rlang::sym(lower_ci)) / (2 * 1.96))^2,
                          weight = 1 / var_smc,  # Weights for degrees of freedom
                          df_adj = (sum(weight)^2) / sum((weight^2) / (rlang::sym(sample_size) - 1)),
                          t_crit = qt(0.975, df = df_adj),
                          var_cum = cumsum(var_smc),
                          lower_ci_nct = rlang::sym(csmc) - t_crit * sqrt(var_cum),
                          upper_ci_nct = rlang::sym(csmc) + t_crit * sqrt(var_cum))
    
    temp <- dplyr::select(temp, -c(weight, df_adj, t_crit))
  }
  
  return(temp)
}
