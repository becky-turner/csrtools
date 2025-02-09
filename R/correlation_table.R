#' Calculates correlation coefficients
#'
#' This function computes pairwise Pearson correlation coefficients for a given dataset.
#' It also computes confidence intervals for the correlations and outputs the
#' results as a table. The table can be saved as a Word document.
#'
#' @param data A data frame or matrix containing the all variables for correlation.
#' @param docname The name of the output MS Word document (if saving to file).
#' @param save_to_doc Logical, whether to save the correlation table to a Word document.
#'
#' @return A correlation table as a data frame.
#' @export
#'
#' @examples
#' # Example data
#' corr_data <- data.frame(
#'   Var1 = c(1, 2, 3, 4, 5),
#'   Var2 = c(2, 4, 6, 8, 10),
#'   Var3 = c(5, 4, 3, 2, 1)
#' )
#'
#' # Generate the correlation table
#' correlation_table(data = corr_data, save_to_doc = FALSE)
#'
correlation_table <- function(data, docname = "Correlation_table", save_to_doc = FALSE) {

  # Ensure 'data' and 'x' are matrices
  data <- as.matrix(data)

  # Perform correlation test
  rcorr_result <- Hmisc::rcorr(data)
  R <- format(round(rcorr_result$r, 2))

  # Add confidence intervals if possible
  for (i in 1:length(R)) {
    if (!is.nan(rcorr_result$r[i]) && !is.nan(rcorr_result$n[i]) && rcorr_result$n[i] > 3) {
      ci <- round(psych::r.con(r = rcorr_result$r[i], n = rcorr_result$n[i], p = 0.95), 2)
      R[i] <- paste(R[i], " [", ci[1], ", ", ci[2], "]")
    } else {
      R[i] <- paste(R[i], " [NA, NA]")  # Placeholder for insufficient data
    }
  }

  # Convert to data frame for output
  R_df <- data.frame(Variable = rownames(rcorr_result$r), R, check.names = FALSE)

  if (save_to_doc) {
    # Create ms word document
    doc <- officer::read_docx()
    doc <- flextable::body_add_flextable(doc, flextable::flextable(R_df))

    # Save file
    print(doc, target = paste0(docname, ".docx"))

    message("Correlation table saved at: ", normalizePath(paste0(docname, ".docx")))
  } else {
    pander::pander(R_df)
  }
}

