#' Generate smoothed cumulative standardised mean change estimates
#'
#' @param smc_dat A data frame containing cumulative SMC data, confidence intervals, and interventions.
#' @param csmc The column name for cumulative SMC values.
#' @param lower_ci The column name for lower CI values.
#' @param upper_ci The column name for upper CI values.
#' @param intervention The column name for intervention groups.
#' @param span The smoothing span for the LOESS model.
#' @param time_series The sequence of time points for prediction.
#'
#' @return A data frame containing smoothed values and the corresponding time points.
#'
#' @examples
#' # Example data frame
#'smc_dat <- data.frame(
#'  smc_cum = c(0.2, 0.3, 0.4, 0.5),
#'  lower_ci_wald = c(0.1, 0.2, 0.3, 0.4),
#'  upper_ci_wald = c(0.3, 0.4, 0.5, 0.6),
#'  intervention = c("Treatment A", "Treatment A", "Treatment B", "Treatment B"),
#'  time_point = c(0, 1, 2, 3)
#')
#'
#'# Smooth the data
#'smc_smooth <- smooth_csmc(
#'  smc_dat = smc_dat,
#'  csmc = "smc_cum",
#'  lower_ci = "lower_ci_wald",
#'  upper_ci = "upper_ci_wald",
#'  intervention = "intervention",
#'  span = 0.6,
#'  time_series = seq(0, 3, 0.1)
#')
#'
#'print(smc_smooth)
#'
#'
#' @importFrom stats quantile
#' @export
#'
smooth_csmc <- function(smc_dat, csmc = "smc_cum",
                        lower_ci = "lower_ci_wald", upper_ci = "upper_ci_wald",
                        intervention = "intervention",
                        span = 0.6, time_series = seq(0, 52, 0.001)) {

  # Define time range
  values <- tibble::tibble(time_point = time_series)

  # Reshape data with a key for parameter (intervention + parameter)
  smc_dat_long <- smc_dat %>%
    tidyr::pivot_longer(cols = c(!!rlang::sym(csmc), !!rlang::sym(lower_ci), !!rlang::sym(upper_ci)),
                        names_to = "parameter") %>%
    dplyr::mutate(parameter_key = paste0(.data[[intervention]], "_", parameter))

  # Define smoothing function with error handling for loess
  smooth_parameter <- function(param_name) {
    filtered_data <- dplyr::filter(smc_dat_long, parameter_key == param_name)

    if (nrow(filtered_data) < 3) {
      # Not enough data for LOESS, return NA
      smoothed_values <- rep(NA, length(time_series))
    } else {
      tryCatch({
        smoothed_values <- stats::loess(value ~ time_point,
                                        data = filtered_data,
                                        span = span) %>%
          stats::predict(newdata = values)
      }, error = function(e) {
        # Handle LOESS errors
        smoothed_values <- rep(NA, length(time_series))
      })
    }

    tibble::tibble(time_point = values$time_point,
                   smoothed_value = smoothed_values,
                   parameter_key = param_name)
  }

  # Apply smoothing for all parameter keys and bind results
  smooth_parameters <- unique(smc_dat_long$parameter_key) %>%
    lapply(smooth_parameter) %>%
    dplyr::bind_rows()

  # Separate the `parameter_key` into `intervention` and `parameter`
  smooth_parameters <- smooth_parameters %>%
    tidyr::separate(parameter_key, into = c("intervention", "parameter"), sep = "_")

  # Join smoothed data back to `values`
  smc_smooth <- values %>%
    dplyr::left_join(smooth_parameters, by = "time_point")

  smc_smooth <- smc_smooth %>%
    dplyr::mutate(dplyr::across(c(smoothed_value),
                                ~ ifelse(time_point >= 0 & time_point < 0.001, 0, .)))

  return(smc_smooth)
}
