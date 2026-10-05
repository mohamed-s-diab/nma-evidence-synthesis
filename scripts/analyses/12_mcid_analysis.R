# ==============================================================================
# Script: scripts/analyses/12_mcid_analysis.R
# Purpose: Minimal Clinically Important Difference (MCID) Decision Framework Engine
# Methodology: ASCO / ESMO-MCBS Framework (>= 20% Mortality Reduction, HR <= 0.80)
# Implementation: 10,000 Monte Carlo Multivariate Normal Draws from Network Covariance
# Outputs: outputs/models/mcid_analysis_data.rds
#          outputs/tables/mcid_superiority_summary.csv
#          outputs/tables/mcid_pairwise_matrix.csv
#          outputs/tables/mcid_superiority_matrix.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
  library(MASS)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 12/12] MCID CLINICAL SUPERIORITY DECISION FRAMEWORK\n")
cat("======================================================================\n")

model_file     <- "outputs/models/mcid_analysis_data.rds"
summary_file   <- "outputs/tables/mcid_superiority_summary.csv"
pairwise_file  <- "outputs/tables/mcid_pairwise_matrix.csv"
matrix_file    <- "outputs/tables/mcid_superiority_matrix.csv"
nma_file       <- "outputs/models/nma_model.rds"
script_file    <- "scripts/analyses/12_mcid_analysis.R"

# 1. Dependency Validation & Smart Cache Invalidation
if (!file.exists(nma_file)) {
  cat(" - Baseline NMA model missing. Fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

force_refit <- (exists("force_refit") && isTRUE(force_refit))
nma_mod     <- file.exists(model_file) && (file.mtime(nma_file) > file.mtime(model_file))
script_mod  <- file.exists(model_file) && (file.mtime(script_file) > file.mtime(model_file))
cache_valid <- !force_refit && 
               file.exists(model_file) && 
               file.exists(summary_file) && 
               file.exists(pairwise_file) && 
               !nma_mod && !script_mod

if (cache_valid) {
  cat(sprintf(" - Existing MCID Analysis cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant simulation. To force refit, set force_refit <- TRUE\n")
  mcid_data <- readRDS(model_file)
} else {
  cat(" - Simulating 10,000 Monte Carlo draws from multivariate normal covariance ...\n")
  nma <- readRDS(nma_file)
  
  trts_all    <- nma$trts
  ref_trt     <- "Drug A"
  trts_active <- setdiff(trts_all, ref_trt)
  
  # Extract submatrix covariance of active treatments vs reference
  comp_names <- paste0(ref_trt, ":", trts_active)
  cov_sub    <- nma$Cov.random[comp_names, comp_names]
  mu_active  <- nma$TE.random[trts_active, ref_trt]
  
  # Set seed for exact numerical reproducibility across pipeline runs
  set.seed(42)
  B <- 10000
  draws_active <- mvrnorm(n = B, mu = mu_active, Sigma = cov_sub)
  colnames(draws_active) <- trts_active
  
  # Reference arm (Drug A anchor) has log(HR) = 0
  draws_ref <- matrix(0, nrow = B, ncol = 1, dimnames = list(NULL, "Drug A"))
  draws_all <- cbind(draws_ref, draws_active)
  draws_all <- draws_all[, trts_all] # preserve canonical treatment order
  
  # ----------------------------------------------------------------------------
  # 2. MCID vs Drug A Anchor Calculations
  # ----------------------------------------------------------------------------
  # MCID Threshold: HR <= 0.80 (>= 20% relative mortality reduction, ASCO/ESMO)
  # Sensitivity Thresholds: HR <= 0.85 (>= 15%) and HR <= 0.75 (>= 25%)
  # Any Superiority: HR < 1.00
  p_mcid_chemo   <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(0.0)
    mean(exp(draws_all[, trt]) <= 0.80)
  })
  
  p_mcid_085     <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(0.0)
    mean(exp(draws_all[, trt]) <= 0.85)
  })
  
  p_mcid_075     <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(0.0)
    mean(exp(draws_all[, trt]) <= 0.75)
  })
  
  p_sup_chemo    <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(0.0)
    mean(exp(draws_all[, trt]) < 1.00)
  })
  
  median_hr <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(1.000)
    median(exp(draws_all[, trt]))
  })
  
  ci_lower_hr <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(1.000)
    quantile(exp(draws_all[, trt]), probs = 0.025)
  })
  
  ci_upper_hr <- sapply(trts_all, function(trt) {
    if (trt == "Drug A") return(1.000)
    quantile(exp(draws_all[, trt]), probs = 0.975)
  })
  
  # ----------------------------------------------------------------------------
  # 3. Complete 6x6 Pairwise MCID & Superiority Matrices
  # ----------------------------------------------------------------------------
  n_trts <- length(trts_all)
  mcid_pairwise_mat    <- matrix(0, nrow = n_trts, ncol = n_trts,
                                 dimnames = list(trts_all, trts_all))
  mcid_superiority_mat <- matrix(NA, nrow = n_trts, ncol = n_trts,
                                 dimnames = list(trts_all, trts_all))
  sup_pairwise_mat     <- matrix(0, nrow = n_trts, ncol = n_trts,
                                 dimnames = list(trts_all, trts_all))
  
  for (i in seq_along(trts_all)) {
    for (j in seq_along(trts_all)) {
      if (i != j) {
        # log(HR_i vs j) = draws_i - draws_j
        diff_draws <- draws_all[, trts_all[i]] - draws_all[, trts_all[j]]
        hr_ij <- exp(diff_draws)
        
        prob_mcid <- mean(hr_ij <= 0.80)
        prob_sup  <- mean(hr_ij < 1.00)
        
        mcid_pairwise_mat[i, j]    <- round(prob_mcid, 4)
        mcid_superiority_mat[i, j] <- round(prob_mcid, 4)
        sup_pairwise_mat[i, j]     <- round(prob_sup, 4)
      }
    }
  }
  
  # ----------------------------------------------------------------------------
  # 4. Clinical Evidence Certainty Tier Classification
  # ----------------------------------------------------------------------------
  classify_tier <- function(p_mcid, trt) {
    if (trt == "Drug A") return("Reference Anchor")
    if (p_mcid >= 0.80) return("Tier 1: Definitive Clinical Superiority (P >= 80%)")
    if (p_mcid >= 0.50) return("Tier 2: Probable Clinical Superiority (50% <= P < 80%)")
    if (p_mcid >= 0.20) return("Tier 3: Inconclusive / Marginal Superiority (20% <= P < 50%)")
    return("Tier 4: Unlikely Clinical Superiority (P < 20%)")
  }
  
  evidence_tiers <- mapply(classify_tier, p_mcid_chemo, trts_all)
  
  # Build Publication-Grade Summary Table
  df_summary <- data.frame(
    Treatment           = trts_all,
    Median_Simulated_HR = round(median_hr, 3),
    Simulated_95_CrI    = sprintf("%.2f-%.2f", ci_lower_hr, ci_upper_hr),
    P_MCID_vs_Chemo     = round(p_mcid_chemo, 4),
    P_MCID_085          = round(p_mcid_085, 4),
    P_MCID_075          = round(p_mcid_075, 4),
    P_Superior_vs_Chemo = round(p_sup_chemo, 4),
    Evidence_Tier       = evidence_tiers,
    stringsAsFactors    = FALSE
  )
  # Sort by P_MCID_vs_Chemo descending
  df_summary <- df_summary[order(-df_summary$P_MCID_vs_Chemo), ]
  rownames(df_summary) <- NULL
  
  # ----------------------------------------------------------------------------
  # 5. Serialization & Table Exports
  # ----------------------------------------------------------------------------
  mcid_data <- list(
    B                    = B,
    threshold_mcid       = 0.80,
    trts                 = trts_all,
    p_mcid_chemo         = p_mcid_chemo,
    p_mcid_085           = p_mcid_085,
    p_mcid_075           = p_mcid_075,
    p_sup_chemo          = p_sup_chemo,
    median_hr            = median_hr,
    ci_lower_hr          = ci_lower_hr,
    ci_upper_hr          = ci_upper_hr,
    mcid_pairwise_mat    = mcid_pairwise_mat,
    mcid_superiority_mat = mcid_superiority_mat,
    sup_pairwise_mat     = sup_pairwise_mat,
    summary_table        = df_summary,
    raw_draws_sample     = draws_all[1:500, ]
  )
  
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(mcid_data, model_file)
  write.csv(df_summary, summary_file, row.names = FALSE)
  write.csv(mcid_pairwise_mat, pairwise_file)
  write.csv(mcid_superiority_mat, matrix_file)
  
  cat(sprintf(" - Saved MCID Summary Table     : %s\n", summary_file))
  cat(sprintf(" - Saved Pairwise MCID Matrix   : %s\n", pairwise_file))
  cat(sprintf(" - Saved Superiority Matrix     : %s\n", matrix_file))
  cat(sprintf(" - Serialized MCID Data Object  : %s\n", model_file))
  
  cat("\n [MCID CLINICAL SUPERIORITY DECISION AUDIT]\n")
  for (i in seq_len(nrow(df_summary))) {
    trt <- df_summary$Treatment[i]
    cat(sprintf("   %d. %-10s | Median HR: %.2f [%s] | P(MCID <= 0.80): %5.1f%% | P(HR < 1.0): %5.1f%% | %s\n",
                i, trt, df_summary$Median_Simulated_HR[i], df_summary$Simulated_95_CrI[i],
                df_summary$P_MCID_vs_Chemo[i] * 100, df_summary$P_Superior_vs_Chemo[i] * 100,
                df_summary$Evidence_Tier[i]))
  }
}

cat(" [SUCCESS] MCID clinical superiority decision framework analysis completed cleanly.\n")
