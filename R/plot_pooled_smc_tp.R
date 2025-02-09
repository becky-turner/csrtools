#' Plot time-series of pooled standardised mean change (SMC) estimates
#'
#' This function generates a plot of the pooled standardized mean change (SMC) over time
#' with confidence intervals. Optionally, the plot can be saved to a specified file path.
#'
#' @param pooled_data A data frame containing the pooled SMC data, with columns for the effect size,
#'   confidence intervals (`lower_ci`, `upper_ci`), and time points.
#' @param x A string specifying the column name for the x-axis (default: `"time_point"`).
#' @param y A string specifying the column name for the y-axis (default: `"smc"`).
#' @param save_path A string specifying the file path to save the plot as an image (optional).
#'
#' @return A `ggplot2` object representing the pooled SMC plot.
#' @details
#' - The plot includes a line for the pooled SMC values, points for the data, and a shaded ribbon for
#'   the confidence intervals.
#' - The x-axis displays the time points, and the y-axis represents the pooled effect size.
#' - The function uses `rlang::sym` for dynamic column names and `ggplot2` for visualization.
#'
#' @examples
#' # Example pooled data
#' pooled_data <- data.frame(
#'   time_point = c(1, 2, 4, 8),
#'   smc = c(0.2, 0.4, 0.6, 0.8),
#'   lower_ci = c(0.1, 0.3, 0.5, 0.7),
#'   upper_ci = c(0.3, 0.5, 0.7, 0.9),
#'   time_unit = "weeks"
#' )
#'
#' # Generate plot
#' plot <- plot_pooled_smc_tp(pooled_data)
#'
#' @export
plot_pooled_smc_tp <- function(pooled_data, x = "time_point", y = "smc", save_path = NULL) {
  # Use package-specific functions
  x_sym <- rlang::sym(x)
  y_sym <- rlang::sym(y)

  # Create the plot
  p <- ggplot2::ggplot(pooled_data, ggplot2::aes(x = !!x_sym, y = !!y_sym)) +
    ggplot2::geom_line(color = "black", linewidth = 1) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lower_ci, ymax = upper_ci), fill = "gray70", alpha = 0.3) +
    ggplot2::scale_x_continuous() +
    ggplot2::labs(x = paste0("Time (", pooled_data$time_unit[1], ")"),
                  y = "Pooled effect size") +
    ggplot2::theme_minimal()

  # Save the plot if a path is provided
  if (!is.null(save_path)) {
    ggplot2::ggsave(save_path, p, width = 8, height = 6, dpi = 500)
  }

  return(p)
}
