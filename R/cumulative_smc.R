#' Calculate cumulative effects
#'
#' This function calculates the cumulative standardised mean change (SMC) over time
#' for a given dataset. It sorts the input dataset by the specified
#' time variable and calculates the cumulative sum of the defined SMC values. Optionally,
#' an intervention label can be added to the data.
#'
#' @param data A data frame containing the data for analysis.
#' @param smc_var Character parameter. The column name in `data` that contains the SMC values (numeric variable). Default is `"smc"`.
#' @param time_var Character parameter. The column name in `data` that contains the time variable (numeric variable). Default is `"time_point"`.
#' @param intervention Character. An optional string specifying the name of the intervention to include as a new column. Default is `NULL`.
#'
#' @return A data frame with the following additional columns:
#' \describe{
#'   \item{\code{smc_cum}}{The cumulative sum of the SMC values.}
#'   \item{\code{intervention}}{(Optional) A column with the specified intervention name, if provided.}
#' }
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(
#'   time_point = c(0, 1, 2, 3),
#'   smc = c(0, 0.5, -0.3, 0.8)
#' )
#'
#' # Run the function
#' result <- cumulative_smc(
#'   data = example_data,
#'   smc_var = "smc",
#'   time_var = "time_point",
#'   intervention = "Intervention A"
#' )
#'
#' # View the result
#' print(result)
#'
#' @export
cumulative_smc <- function(data, smc_var = "smc", time_var = "time_point", intervention = NULL) {

  # Ensure time variable is numeric
  data[[time_var]] <- as.numeric(data[[time_var]])

  # Sort the data by time variable to ensure proper calculation
  data <- data[order(data[[time_var]]), ]

  # Calculate cumulative changes
  data$smc_cum <- cumsum(data[[smc_var]])

  # Add intervention name if provided
  if (!is.null(intervention)) {
    data$intervention <- intervention
  }

  # Return the data
  return(data)
}
