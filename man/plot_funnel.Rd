% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_funnel.R
\name{plot_funnel}
\alias{plot_funnel}
\title{Generate funnel plot}
\usage{
plot_funnel(smc_result, time_point, time_unit)
}
\arguments{
\item{smc_result}{An object of class `rma` created by the `metafor::rma()` function,
representing the results of the meta-analysis.}

\item{time_point}{A numeric or character value specifying the time points (e.g., "6" for 6 weeks).}

\item{time_unit}{A string specifying the unit of time (e.g., "weeks", "months") to display in the x axis title.}
}
\value{
Returns a funnel plot as a `recordedplot` object. The plot visualizes
the effect size estimates (e.g., standardized mean changes) against their standard errors.
}
\description{
This function generates a funnel plot to assess publication bias or heterogeneity in a meta-analysis.
Funnel plots visualize the relationship between effect size estimates and their standard errors.
}
\details{
- The function uses the `metafor::funnel()` function to create the funnel plot.
- The input data are generated in the `smc_tp` function.
- The `xlab` argument specifies the x-axis label as "Standardised Mean Change (SMC)".
- The subtitle of the plot (`sub`) includes the time point and time unit for context.
}
\examples{
# Example meta-analysis data
ma_data <- data.frame(
  study_id = c("Study 1", "Study 2", "Study 3"),
  smc = c(0.2, 0.5, -0.1),
  smc_variance = c(0.04, 0.06, 0.03)
)

smc_result <- metafor::rma(yi = smc, vi = smc_variance, data = ma_data, method = "REML")

# Generate funnel plot
funnel_plot <- plot_funnel(smc_result, time_point = "6", time_unit = "weeks")

# Display the plot
print(funnel_plot)

}
