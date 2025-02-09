#' Run meta-analysis and generate pooled standardised mean change estimates
#'
#' @param data A data frame containing study-level data.
#' @param outcome_means A character vector of column names for outcome means at different time points.
#' @param outcome_sds A character vector of column names for outcome standard deviations at different time points.
#' @param baseline_mean The column name for the baseline mean.
#' @param baseline_sd The column name for the baseline standard deviation.
#' @param sample_size The column name for the sample size.
#' @param time_points A character vector of time points corresponding to `outcome_means` and `outcome_sds`.
#' @param time_unit A string specifying the time unit (e.g., "weeks").
#' @param intervention A string specifying the intervention name (optional).
#' @param plot Logical, whether to plot the pooled results.
#'
#' @return A data frame containing pooled SMC estimates and confidence intervals for each time point.
#' @export
#'
#' @examples
#' data <- data.frame(
#'   study = c("Study 1", "Study 2", "Study 3"),
#'   mean_baseline = c(10, 12, 11),
#'   sd_baseline = c(2, 3, 2.5),
#'   mean_1week = c(8, 10, 9),
#'   sd_1week = c(1.5, 2.5, 2),
#'   mean_2weeks = c(7, 9, 8),
#'   sd_2weeks = c(1.2, 2.3, 1.8),
#'   n_in_arm = c(50, 60, 55)
#' )
#' outcome_means <- c("mean_1week", "mean_2weeks")
#' outcome_sds <- c("sd_1week", "sd_2weeks")
#' time_points <- c("1", "2")
#' time_unit <- "weeks"
#' results <- pooled_smc_tp(data, outcome_means, outcome_sds, "mean_baseline",
#'                          "sd_baseline", "n_in_arm", time_points, time_unit)
pooled_smc_tp <- function(data, outcome_means, outcome_sds,
                          baseline_mean, baseline_sd, sample_size,
                          time_points, time_unit, intervention = NULL, plot = TRUE) {
  meta_analysis_single <- function(data, outcome_mean, outcome_sd, time_point) {
    # Ensure columns exist in the data
    if (!outcome_mean %in% colnames(data) || !outcome_sd %in% colnames(data)) {
      stop(paste("Column", outcome_mean, "or", outcome_sd, "not found in the data"))
    }

    # Filter for valid rows
    valid_data <- data %>%
      dplyr::filter(!is.na(!!rlang::sym(outcome_mean)) & !is.na(!!rlang::sym(outcome_sd)))

    if (nrow(valid_data) > 0) {
      valid_data <- valid_data %>%
        dplyr::mutate(
          smc = (!!rlang::sym(outcome_mean) - !!rlang::sym(baseline_mean)) / !!rlang::sym(baseline_sd),
          smc_variance = (!!rlang::sym(sample_size) + smc^2) / !!rlang::sym(sample_size)
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

  # Plot if required
  if (plot) {
    plot_p <- plot_pooled_smc_tp(results, x = "time_point", y = "smc")
    print(plot_p)
  }

  return(results)
}
