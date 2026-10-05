# ==============================================================================
# Script: scripts/analyses/10_network_metaregression.R
# Purpose: Network Meta-Regression & Transitivity Diagnostics
# Methodology: Salanti (2012) / Jansen & Naci (2013) / netmeta::netmetareg()
# Evaluates Potential Effect Modifiers & Validates Transitivity:
#   1. Publication Year (Temporal Drift / Evolving Supportive Care, 2009-2023)
#   2. Trial Sample Size (log(N) / Small-Study Effects)
#   3. Geographic Setting (Asia-Pacific vs Global Populations)
# Outputs: outputs/models/metaregression_data.rds
#          outputs/tables/metaregression_results.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

# Prevent scientific notation (e.g., display 0.0003 instead of 3e-04)
options(scipen = 10)

cat("\n======================================================================\n")
cat(" [ANALYSIS 10/12] NETWORK META-REGRESSION & TRANSITIVITY AUDIT\n")
cat("======================================================================\n")

model_file   <- "outputs/models/metaregression_data.rds"
table_file   <- "outputs/tables/metaregression_results.csv"
nma_file     <- "outputs/models/nma_model.rds"
data_path    <- "data/trial_contrasts.csv"
script_file  <- "scripts/analyses/10_network_metaregression.R"

if (!file.exists(nma_file)) {
  stop(sprintf("Error: Baseline NMA model not found at '%s'.", nma_file))
}
if (!file.exists(data_path)) {
  stop(sprintf("Error: Contrast dataset not found at '%s'.", data_path))
}

force_refit <- (exists("force_refit") && isTRUE(force_refit))
nma_mod     <- file.exists(model_file) && (file.mtime(nma_file) > file.mtime(model_file))
data_mod    <- file.exists(model_file) && (file.mtime(data_path) > file.mtime(model_file))
script_mod  <- file.exists(model_file) && (file.mtime(script_file) > file.mtime(model_file))
cache_valid <- !force_refit && file.exists(model_file) && file.exists(table_file) && !nma_mod && !data_mod && !script_mod

if (cache_valid) {
  cat(sprintf(" - Existing Meta-Regression cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant estimation. To force refit, set force_refit <- TRUE\n")
  mr_data <- readRDS(model_file)
} else {
  cat(" - Fitting network meta-regression models across key clinical effect modifiers ...\n")
  nma <- readRDS(nma_file)
  dat <- read.csv(data_path, stringsAsFactors = FALSE)
  
  # 1. Publication Year (Centered at median 2020)
  dat$year_c <- dat$year - 2020
  mr_year <- netmetareg(nma, covar = dat$year_c, assumption = "common")
  
  # 2. Trial Sample Size (Centered log(N))
  dat$log_n <- log(dat$n_total) - mean(log(dat$n_total))
  mr_n <- netmetareg(nma, covar = dat$log_n, assumption = "common")
  
  # 3. Geographic Region (Asia-Pacific = 1 vs Global = 0)
  dat$asia <- ifelse(dat$region == "Asia-Pacific", 1, 0)
  mr_reg <- netmetareg(nma, covar = dat$asia, assumption = "common")
  
  # Helper to extract regression parameters from rma object
  extract_mr <- function(mr_obj, covar_name, domain, unit_label) {
    # The covariate slope is the last coefficient
    idx <- length(mr_obj$b)
    b_val   <- mr_obj$b[idx]
    se_val  <- mr_obj$se[idx]
    ci_lb   <- mr_obj$ci.lb[idx]
    ci_ub   <- mr_obj$ci.ub[idx]
    z_val   <- mr_obj$zval[idx]
    p_val   <- mr_obj$pval[idx]
    
    data.frame(
      Covariate      = covar_name,
      Domain         = domain,
      Unit           = unit_label,
      Slope_Beta     = round(b_val, 4),
      SE             = round(se_val, 4),
      CI_Lower       = round(ci_lb, 4),
      CI_Upper       = round(ci_ub, 4),
      Z_Score        = round(z_val, 2),
      P_Value        = p_val,
      P_Value_String = ifelse(p_val < 0.0001, "<0.0001", sprintf("%.4f", p_val)),
      Omnibus_QM     = round(mr_obj$QM, 2),
      QM_Pval        = mr_obj$QMp,
      Transitivity   = ifelse(p_val > 0.05, "Preserved (No Effect Modification)", "Violated (Effect Modifier Detected)"),
      stringsAsFactors = FALSE
    )
  }
  
  df_year <- extract_mr(mr_year, "Publication Year", "Temporal Stability", "Per 1-Year Increase (2009-2023)")
  df_n    <- extract_mr(mr_n,    "Sample Size (log N)", "Small-Study Effects", "Per 1-Unit Increase in log(N)")
  df_reg  <- extract_mr(mr_reg,  "Geographic Setting", "Population Diversity", "Asia-Pacific vs Global Trials")
  
  df_mr_summary <- rbind(df_year, df_n, df_reg)
  
  # Bundle Serialization Data
  mr_data <- list(
    mr_year_obj   = mr_year,
    mr_n_obj      = mr_n,
    mr_reg_obj    = mr_reg,
    summary_table = df_mr_summary,
    trial_data    = dat
  )
  
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(mr_data, model_file)
  write.csv(df_mr_summary, table_file, row.names = FALSE)
  
  cat(sprintf(" - Saved Meta-Regression table : %s (%d covariates)\n", table_file, nrow(df_mr_summary)))
  cat(sprintf(" - Serialized MR data object   : %s\n", model_file))
  
  cat("\n [TRANSITIVITY & EFFECT MODIFICATION AUDIT]\n")
  for (i in 1:nrow(df_mr_summary)) {
    cat(sprintf("   * %-20s | Beta: %7.4f (95%% CI: %7.4f to %7.4f) | p = %s | %s\n",
                df_mr_summary$Covariate[i],
                df_mr_summary$Slope_Beta[i],
                df_mr_summary$CI_Lower[i],
                df_mr_summary$CI_Upper[i],
                df_mr_summary$P_Value_String[i],
                df_mr_summary$Transitivity[i]))
  }
}

cat(" [SUCCESS] Network meta-regression completed cleanly.\n")
