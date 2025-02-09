#### Function to generate the Funnel Plot and store it
plot_funnel <- function(smc_result, time_point, time_unit) {
  funnel(smc_result, 
         xlab = "Standardised Mean Change (SMC)", 
         sub = paste(time_point, time_unit))
  return(recordPlot())  # Capture the plot
}
