# ==============================================================================
# Script: scripts/analyses/01_fit_nma_model.R
# Purpose: Core Frequentist Graph-Theoretical Network Meta-Analysis Model Fitting
# Single Source of Truth for Model Hyperparameters & Serialization (.rds)
# Package: netmeta (Rücker 2012 Electrical Network Analogy)
# Outputs: outputs/models/nma_model.rds
#          outputs/models/nma_rankings.rds
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 01/12] MODEL ESTIMATION & CACHING (SINGLE SOURCE OF TRUTH)\n")
cat("======================================================================\n")

# 1. Load Clinical Trial Contrast Data
data_path <- "data/nsclc_trial_contrasts.csv"
if (!file.exists(data_path)) {
  stop(sprintf("Error: Contrast dataset not found at '%s'. Please ensure the data file exists before running the analysis.", data_path))
}
dat <- read.csv(data_path, stringsAsFactors = FALSE)

model_file   <- "outputs/models/nma_model.rds"
ranking_file <- "outputs/models/nma_rankings.rds"
script_file  <- "scripts/analyses/01_fit_nma_model.R"

# Smart Cache Invalidation: Detect if data or script has changed since last fit
force_refit <- (exists("force_refit") && isTRUE(force_refit))
data_modified <- file.exists(model_file) && (file.mtime(data_path) > file.mtime(model_file))
cache_valid <- !force_refit && 
               file.exists(model_file) && 
               file.exists(ranking_file) && 
               !data_modified

if (cache_valid) {
  cat(sprintf(" - Existing model cache is up-to-date with dataset (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant re-estimation. To force refit, set force_refit <- TRUE\n")
  nma <- readRDS(model_file)
  rk  <- readRDS(ranking_file)
} else {
  if (data_modified) {
    cat(" [DETECTED] Dataset has been modified since last model fit! Automatically re-fitting ...\n")
  } else {
    cat(" - Fitting NMA model from clinical trial contrasts ...\n")
  }
  
  cat(sprintf(" - Loaded contrast dataset: %d comparisons across %d trials\n",
              nrow(dat), length(unique(dat$studlab))))
  cat(sprintf(" - Total patients evaluated: %s\n", 
              format(sum(dat$n_total[!duplicated(dat$studlab)]), big.mark = ",")))

  # 2. Fit Frequentist Graph-Theoretical Model (Single Definition)
  nma <- netmeta(
    TE = TE,
    seTE = seTE,
    treat1 = treat1,
    treat2 = treat2,
    studlab = studlab,
    data = dat,
    sm = "HR",
    reference.group = "Drug A",
    common = TRUE,
    random = TRUE,
    tol.multiarm = 0.005,
    details.chkmultiarm = FALSE
  )

  # 3. Compute Core Hierarchy Ranking (P-scores)
  rk <- netrank(nma, small.values = "good")

  # 4. Serialize Model & Rankings for Lightning-Fast Downstream Reuse (.rds)
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  saveRDS(nma, model_file)
  saveRDS(rk, ranking_file)

  cat(sprintf(" - Cached fitted model: %s (Size: %.1f KB)\n", model_file, file.info(model_file)$size / 1024))
  cat(sprintf(" - Cached rankings object: %s\n", ranking_file))
}

cat("\n [MODEL SUMMARY]\n")
cat(sprintf(" - Treatments (n): %d\n", nma$n))
cat(sprintf(" - Pairwise comparisons (m): %d\n", nma$m))
cat(sprintf(" - Study designs (d): %d\n", nma$d))
cat(sprintf(" - Between-study heterogeneity (tau^2): %.4f (tau = %.4f)\n", nma$tau2, nma$tau))
cat(sprintf(" - Inconsistency/Heterogeneity index (I^2): %.1f%%\n", nma$I2 * 100))
cat(sprintf(" - Total Cochran's Q: %.2f (df = %d, p = %.4f)\n", nma$Q, nma$df.Q, nma$pval.Q))

cat("\n [SUCCESS] Network Meta-Analysis model verified and serialized successfully.\n\n")

