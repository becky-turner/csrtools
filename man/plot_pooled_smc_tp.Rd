% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_pooled_smc_tp.R
\name{plot_pooled_smc_tp}
\alias{plot_pooled_smc_tp}
\title{Plot time-series of pooled standardised mean change (SMC) estimates}
\usage{
plot_pooled_smc_tp(pooled_data, x = "time_point", y = "smc", save_path = NULL)
}
\arguments{
\item{pooled_data}{A data frame containing the pooled SMC data, with columns for the effect size,
confidence intervals (`lower_ci`, `upper_ci`), and time points.}

\item{x}{A string specifying the column name for the x-axis (default: `"time_point"`).}

\item{y}{A string specifying the column name for the y-axis (default: `"smc"`).}

\item{save_path}{A string specifying the file path to save the plot as an image (optional).}
}
\value{
A `ggplot2` object representing the pooled SMC plot.
}
\description{
This function generates a plot of the pooled standardized mean change (SMC) over time
with confidence intervals. Optionally, the plot can be saved to a specified file path.
}
\details{
- The plot includes a line for the pooled SMC values, points for the data, and a shaded ribbon for
  the confidence intervals.
- The x-axis displays the time points, and the y-axis represents the pooled effect size.
- The function uses `rlang::sym` for dynamic column names and `ggplot2` for visualization.
}
\examples{
# Example pooled data
pooled_data <- data.frame(
  time_point = c(1, 2, 4, 8),
  smc = c(0.2, 0.4, 0.6, 0.8),
  lower_ci = c(0.1, 0.3, 0.5, 0.7),
  upper_ci = c(0.3, 0.5, 0.7, 0.9),
  time_unit = "weeks"
)

# Generate plot
plot <- plot_pooled_smc_tp(pooled_data)

}
