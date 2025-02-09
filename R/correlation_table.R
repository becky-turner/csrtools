correlation_table <- function(x, data, docname = "Correlation_table", save_to_doc = FALSE) {
  
  #library(Hmisc)
  #library(psych)
  #library(pander)
  #library(flextable)
  #library(officer)
  
  # Ensure 'data' and 'x' are matrices
  data <- as.matrix(data)
  x <- as.matrix(x)
  
  # Perform correlation test
  corr_test <- psych::corr.test(data, adjust = "none")
  rcorr_result <- Hmisc::rcorr(x)
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
    # Create Word document
    doc <- officer::read_docx()
    doc <- flextable::body_add_flextable(doc, flextable::flextable(R_df))
    
    # Save file
    print(doc, target = paste0(docname, ".docx"))
    
    message("Correlation table saved at: ", normalizePath(paste0(docname, ".docx")))
  } else {
    pander::pander(R_df)
  }
}

