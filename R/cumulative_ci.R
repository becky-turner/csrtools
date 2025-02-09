#' Calculate cumulative standardised mean change confidence intervals
#'
#' @param data Input data frame containing required variables for confidence interval calculation.
#' @param csmc Name of variable containing cumulative standardised mean change values.
#' @param upper_ci Name of variable containing upper-bound confidence interval values.
#' @param lower_ci Name of variable containing lower-bound confidence interval values.
#' @param time_point Name of variable containing time points.
#' @param n_boot Number of bootstrap samples for the bootstrap method.
#' @param sample_size Name of variable containing sample sizes (required for nct method).
#' @param method Method to calculate confidence intervals: "fixed", "wald", "bootstrap", or "nct".
#'
#' @return A data frame with additional columns for confidence intervals.
#' @export
#'
#' @examples
#' # Example dataset
#' data <- data.frame(
#'   smc_cum = c(0.5, 0.8, 1.2),
#'   upper_ci = c(0.7, 1.1, 1.5),
#'   lower_ci = c(0.3, 0.5, 0.9),
#'   time_point = c(1, 2, 3),
#'   total_sample = c(50, 50, 50)
#' )
#'
#' # Fixed method
#' cumulative_ci(data, method = "fixed")
cumulative_ci <- function(data, csmc = "smc_cum", upper_ci = "upper_ci", lower_ci = "lower_ci",
                          time_point = "time_point", n_boot = 1000, # bootstrap parameters
                          sample_size = "total_sample", # nct parameters
                          method) {

  # Copy data to avoid modifying the original dataset
  temp <- data

  if (method == "fixed") {
    # Fixed-width CI method (additive variance approach)
    temp <- temp %>%
      dplyr::mutate(lower_ci_fixed = !!rlang::sym(csmc) - ((.data[[upper_ci]] - .data[[lower_ci]]) / 2),
                    upper_ci_fixed = !!rlang::sym(csmc) + ((.data[[upper_ci]] - .data[[lower_ci]]) / 2))
  }

  if (method == "wald") {
    # Wald-based method (propagated cumulative variance approach)
    temp <- temp %>%
      dplyr::mutate(var_cum = cumsum((.data[[upper_ci]] - .data[[lower_ci]])^2 / (2 * 1.96)^2),
                    lower_ci_wald = !!rlang::sym(csmc) - 1.96 * sqrt(var_cum),
                    upper_ci_wald = !!rlang::sym(csmc) + 1.96 * sqrt(var_cum))
  }

  if (method == "bootstrap") {
    # Bootstrap-based confidence intervals (cumulative bootstrap approach)
    bootstrap_smc <- function(data, indices) {
      # Resample data
      boot_data <- data[indices, ]

      # Compute cumulative SMC
      boot_data <- boot_data %>%
        dplyr::arrange(.data[[time_point]]) %>%
        dplyr::mutate(smc_cum = .data[[csmc]])

      return(boot_data$smc_cum)  # Return cumulative SMC values
    }

    # Run the bootstrap
    boot_results <- boot::boot(data = temp, statistic = bootstrap_smc, R = n_boot)

    # Convert bootstrap samples into a dataframe
    boot_samples <- as.data.frame(boot_results$t)

    # Compute confidence intervals using percentiles
    boot_ci <- apply(boot_samples, 2, function(x) quantile(x, probs = c(0.025, 0.975)))

    # Add bootstrapped confidence intervals to the dataset
    temp <- temp %>%
      dplyr::mutate(lower_ci_bootstrap = boot_ci[1, ],  # 2.5th percentile
                    upper_ci_bootstrap = boot_ci[2, ])   # 97.5th percentile
  }

  if (method == "nct") {
    # Non-central t-distribution method
    temp <- temp %>%
      dplyr::mutate(var_smc = ((.data[[upper_ci]] - .data[[lower_ci]]) / (2 * 1.96))^2,
                    weight = 1 / var_smc,  # Weights for degrees of freedom
                    df_adj = (sum(weight)^2) / sum((weight^2) / (.data[[sample_size]] - 1)),
                    t_crit = stats::qt(0.975, df = df_adj),
                    var_cum = cumsum(var_smc),
                    lower_ci_nct = !!rlang::sym(csmc) - t_crit * sqrt(var_cum),
                    upper_ci_nct = !!rlang::sym(csmc) + t_crit * sqrt(var_cum))

    temp <- dplyr::select(temp, -c(weight, df_adj, t_crit))
  }

  return(temp)
}
