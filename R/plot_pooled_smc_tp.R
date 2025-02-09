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
