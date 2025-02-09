#' Run meta analsyis and compute standardised mean change (SMC) estimates from time points
#'
#' This function calculates the standardised mean change (SMC) from a starting time point and an outcome time point.
#' It optionally applies Hedges' g correction for small sample sizes, performs a random-effects meta-analysis,
#' and generates forest and funnel plots.
#'
#' @param data A data frame containing the study data.
#' @param mean_from Name of the column with baseline mean values (default is `"mean_baseline"`).
#' @param sd_from Name of the column with baseline standard deviation values (default is `"sd_baseline"`).
#' @param outcome_mean Name of the column with mean values at the specified outcome time point.
#' @param outcome_sd Name of the column with standard deviation values at the specified outcome time point.
#' @param sample_size Name of the column with the sample size for each study (default is `"n_in_arm"`).
#' @param study_id Name of the column identifying individual studies (default is `"author_arm"`).
#' @param time_unit A character string representing the unit of time (e.g., `"weeks"`).
#' @param time_point A numeric value specifying the time point being analyzed.
#' @param hedges Logical. If `TRUE`, applies Hedges' g correction for small sample sizes (default is `FALSE`).
#' @param plot Logical. If `TRUE`, generates forest and funnel plots for the meta-analysis results (default is `FALSE`).
#' @param save_path A character string specifying the file path to save the plots. If `NULL`, plots are not saved (default is `NULL`).
#' @param heterogeneity Logical. If `TRUE`, includes heterogeneity statistics (`I²`, Cochran’s Q, and τ²) in the output (default is `FALSE`).
#'
#' @return A data frame containing the following columns:
#' \itemize{
#'   \item \code{time_point}: The specified time point.
#'   \item \code{total_sample}: The total sample size used in the time point meta-analysis.
#'   \item \code{smc}: The pooled standardised mean change estimate.
#'   \item \code{lower_ci}: The lower bound of the confidence interval for the pooled SMC.
#'   \item \code{upper_ci}: The upper bound of the confidence interval for the pooled SMC.
#'   \item \code{I2} (if \code{heterogeneity = TRUE}): The I² statistic indicating heterogeneity.
#'   \item \code{Q} (if \code{heterogeneity = TRUE}): Cochran’s Q statistic.
#'   \item \code{tau2} (if \code{heterogeneity = TRUE}): Between-study variance.
#' }
#'
#' @export
#'
#' @examples
#' # Example data frame
#' data <- data.frame(
#'   mean_baseline = c(2.1, 2.4, 1.8),
#'   sd_baseline = c(0.5, 0.6, 0.4),
#'   mean_2weeks = c(3.1, 3.3, 2.5),
#'   sd_2weeks = c(0.5, 0.6, 0.5),
#'   n_in_arm = c(50, 60, 45),
#'   author_arm = c("Study 1", "Study 2", "Study 3")
#' )
#'
#' # Compute SMC without Hedges' correction
#' smc_tp(data,
#'        mean_from = "mean_baseline",
#'        sd_from = "sd_baseline",
#'        outcome_mean = "mean_2weeks",
#'        outcome_sd = "sd_2weeks",
#'        sample_size = "n_in_arm",
#'        study_id = "author_arm",
#'        time_unit = "weeks",
#'        time_point = 2,
#'        hedges = FALSE,
#'        plot = TRUE)
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

  # Compute the standardised mean change and its variance
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
