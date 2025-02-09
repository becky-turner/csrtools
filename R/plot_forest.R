#' Generate forest plot
#'
#' This function generates a forest plot to visualise the standardised mean change (SMC)
#' results from a meta-analysis, including individual study estimates and the overall pooled estimates.
#'
#' @param smc_result An object of class `rma` created by the `metafor::rma()` function,
#' representing the results of the meta-analysis.
#' @param ma_data A data frame containing the study-level data used in the meta-analysis.
#' @param study_id A string specifying the column name in `ma_data` that contains the
#' study identifiers or labels for each study arm.
#' @param time_point A numeric or character value specifying the time points (e.g., "6" for 6 weeks).
#' @param time_unit A string specifying the unit of time (e.g., "weeks", "months") to display in the x axis title.
#'
#' @return Returns a forest plot as a `recordedplot` object. The plot visualizes
#' individual study SMC estimates and  confidence intervals, along with the
#' overall pooled SMC estimate and confidence interval.
#'
#' @details
#' - The function uses the `metafor::forest()` function to create the forest plot.
#' - The input datasets are generated in the `smc_tp` function.
#' - The `slab` parameter is used to label each study with the study identifier from the specified column in `ma_data`.
#' - The `xlab` argument specifies the x-axis label as "Standardised Mean Change (SMC)".
#' - The subtitle of the plot (`sub`) includes the time point and time unit for context.
#'
#' @examples
#' # Example meta-analysis data
#' ma_data <- data.frame(
#'   study_id = c("Study 1", "Study 2", "Study 3"),
#'   smc = c(0.2, 0.5, -0.1),
#'   smc_variance = c(0.04, 0.06, 0.03)
#' )
#'
#' smc_result <- metafor::rma(yi = smc, vi = smc_variance, data = ma_data, method = "REML")
#'
#' # Generate forest plot
#' forest_plot <- plot_forest(smc_result, ma_data, study_id = "study_id",
#'                            time_point = "6", time_unit = "weeks")
#'
#' # Display the plot
#' print(forest_plot)
#'
#' @export
#'
plot_forest <- function(smc_result, ma_data, study_id, time_point, time_unit) {
  metafor::forest(smc_result, slab = ma_data[[study_id]],
         xlab = "Standardised Mean Change (SMC)",
         sub = paste(time_point, time_unit))
  return(recordPlot())
}
