smooth_csmc <- function(smc_dat, csmc = "smc_cum", 
                        lower_ci = "lower_ci_wald", upper_ci = "upper_ci_wald",
                        intervention = "intervention",
                        span = 0.4, time_series = seq(0, 52, 0.001)) {
  
  # Define time range
  values <- tibble::tibble(time_point = time_series)
  
  # Reshape data with a key for parameter (intervention + parameter)
  smc_dat_long <- smc_dat %>%
    tidyr::pivot_longer(cols = c(!!rlang::sym(csmc), !!rlang::sym(lower_ci), !!rlang::sym(upper_ci)), 
                        names_to = "parameter") %>%
    dplyr::mutate(parameter = dplyr::recode(parameter, 
                                            !!csmc := "csmc", 
                                            !!lower_ci := "lower", 
                                            !!upper_ci := "upper"),
                  parameter_key = paste0(.data[[intervention]], "_", parameter))
  
  # Define smoothing function
  smooth_parameter <- function(param_name) {
    smoothed_values <- stats::loess(value ~ time_point, 
                                    data = dplyr::filter(smc_dat_long, parameter_key == param_name), 
                                    span = span) %>% 
      stats::predict(newdata = values)
    
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
