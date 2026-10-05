# ==============================================================================
# Script: scripts/analyses/04_inconsistency_tests.R
# Purpose: Global Q Variance Decomposition & Inconsistency Diagnostics
# Input:   outputs/models/nma_model.rds
# Output:  outputs/tables/inconsistency_statistics.csv
# Package: netmeta (Design-by-Treatment Interaction Model)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 04/12] INCONSISTENCY EVALUATION (GLOBAL Q DECOMPOSITION)\n")
cat("======================================================================\n")

# 1. Load Cached Model (Auto-fit if missing or data changed)
model_path <- "outputs/models/nma_model.rds"
data_path  <- "data/trial_contrasts.csv"

needs_refit <- !file.exists(model_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(model_path))

if (needs_refit) {
  cat(" - Data updated or cached model missing. Fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

load_start_time <- Sys.time()
nma <- readRDS(model_path)
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached model in %.3f seconds.\n", load_time_taken))

# 2. Global Inconsistency: Decomposition of Cochran's Q
# Q_total = Q_within (heterogeneity) + Q_between (inconsistency)
df_inconsistency <- data.frame(
  Source = c("Total Variation (Q)", "Within-Designs Heterogeneity (Q_het)", "Between-Designs Inconsistency (Q_inc)"),
  Q_Statistic = round(c(nma$Q, nma$Q.heterogeneity, nma$Q.inconsistency), 2),
  Degrees_of_Freedom = c(nma$df.Q, nma$df.Q.heterogeneity, nma$df.Q.inconsistency),
  P_Value = sprintf("%.4f", c(nma$pval.Q, nma$pval.Q.heterogeneity, nma$pval.Q.inconsistency)),
  Interpretation = c(
    ifelse(nma$pval.Q > 0.05, "No significant total excess variance", "Significant total variation"),
    ifelse(nma$pval.Q.heterogeneity > 0.05, "Homogeneity within trial designs", "Heterogeneity within designs"),
    ifelse(nma$pval.Q.inconsistency > 0.05, "Full Transitivity/Consistency upheld", "Evidence of Inconsistency")
  ),
  stringsAsFactors = FALSE
)

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
output_tbl <- "outputs/tables/inconsistency_statistics.csv"
write.csv(df_inconsistency, output_tbl, row.names = FALSE)
cat(sprintf(" - Exported global inconsistency table to: %s\n\n", output_tbl))
print(df_inconsistency)
cat("\n")
