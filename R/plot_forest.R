#### Function to generate the Forest Plot and store it
plot_forest <- function(smc_result, ma_data, study_id, time_point, time_unit) {
  forest(smc_result, slab = ma_data[[study_id]], 
         xlab = "Standardised Mean Change (SMC)", 
         sub = paste(time_point, time_unit))
  return(recordPlot())
}