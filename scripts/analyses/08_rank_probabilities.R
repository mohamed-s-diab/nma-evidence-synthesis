# ==============================================================================
# Script: scripts/analyses/08_rank_probabilities.R
# Purpose: Probabilistic Treatment Hierarchy & Monte Carlo Rank Probability Engine
# Methodology: Salanti et al. (2011) / Rücker & Schwarzer (2015)
# Implementation: 10,000 Monte Carlo Multivariate Normal Draws from Network Covariance
# Outputs: outputs/models/rank_probabilities_data.rds
#          outputs/tables/rank_probabilities_matrix.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
  library(MASS)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 08/12] MONTE CARLO PROBABILISTIC TREATMENT HIERARCHY & SUCRA\n")
cat("======================================================================\n")

model_file  <- "outputs/models/rank_probabilities_data.rds"
table_file  <- "outputs/tables/rank_probabilities_matrix.csv"
nma_file    <- "outputs/models/nma_model.rds"
script_file <- "scripts/analyses/08_rank_probabilities.R"

if (!file.exists(nma_file)) {
  stop(sprintf("Error: Baseline NMA model not found at '%s'.", nma_file))
}

force_refit <- (exists("force_refit") && isTRUE(force_refit))
nma_mod     <- file.exists(model_file) && (file.mtime(nma_file) > file.mtime(model_file))
script_mod  <- file.exists(model_file) && (file.mtime(script_file) > file.mtime(model_file))
cache_valid <- !force_refit && file.exists(model_file) && file.exists(table_file) && !nma_mod && !script_mod

if (cache_valid) {
  cat(sprintf(" - Existing Rank Probabilities cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant simulation. To force refit, set force_refit <- TRUE\n")
  rank_data <- readRDS(model_file)
} else {
  cat(" - Simulating 10,000 Monte Carlo draws from multivariate normal covariance ...\n")
  nma <- readRDS(nma_file)
  
  trts_all    <- nma$trts
  ref_trt     <- "Drug A"
  trts_active <- setdiff(trts_all, ref_trt)
  
  # Extract submatrix covariance of treatments vs reference
  comp_names <- paste0(ref_trt, ":", trts_active)
  cov_sub    <- nma$Cov.random[comp_names, comp_names]
  mu_active  <- nma$TE.random[trts_active, ref_trt]
  
  # Set seed for reproducible publication-grade draws
  set.seed(42)
  B <- 10000
  draws_active <- mvrnorm(n = B, mu = mu_active, Sigma = cov_sub)
  colnames(draws_active) <- trts_active
  
  # Reference arm (Drug A) has log(HR) = 0
  draws_ref <- matrix(0, nrow = B, ncol = 1, dimnames = list(NULL, "Drug A"))
  draws_all <- cbind(draws_ref, draws_active)
  draws_all <- draws_all[, trts_all] # preserve canonical order
  
  # Rank for each draw (1 = best survival extension, lowest log HR)
  ranks <- t(apply(draws_all, 1, rank))
  
  # Compute Rank Probability Matrix
  n_trts <- length(trts_all)
  rank_prob_mat <- matrix(0, nrow = n_trts, ncol = n_trts)
  rownames(rank_prob_mat) <- trts_all
  colnames(rank_prob_mat) <- paste0("Rank_", 1:n_trts)
  
  for (trt in trts_all) {
    for (r in 1:n_trts) {
      rank_prob_mat[trt, r] <- mean(ranks[, trt] == r)
    }
  }
  
  # Cumulative Rank Probabilities & SUCRA Scores
  cum_prob_mat <- t(apply(rank_prob_mat, 1, cumsum))
  sucra_scores <- rowSums(cum_prob_mat[, 1:(n_trts - 1)]) / (n_trts - 1)
  
  # Mean Rank
  mean_ranks <- rowSums(rank_prob_mat * matrix(rep(1:n_trts, each = n_trts), nrow = n_trts, byrow = FALSE))
  
  # Build Summary Table
  df_summary <- data.frame(
    Treatment = trts_all,
    SUCRA     = round(sucra_scores, 4),
    Mean_Rank = round(mean_ranks, 2),
    round(rank_prob_mat, 4),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  # Sort by SUCRA descending
  df_summary <- df_summary[order(-df_summary$SUCRA), ]
  rownames(df_summary) <- NULL
  
  # Bundle Serialization Data
  rank_data <- list(
    B                = B,
    trts             = trts_all,
    rank_prob_mat    = rank_prob_mat,
    cum_prob_mat     = cum_prob_mat,
    sucra_scores     = sucra_scores,
    mean_ranks       = mean_ranks,
    summary_table    = df_summary,
    raw_ranks_sample = ranks[1:500, ], # sample for quick audit
    draws_all_sample = draws_all[1:500, ]
  )
  
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(rank_data, model_file)
  write.csv(df_summary, table_file, row.names = FALSE)
  
  cat(sprintf(" - Saved Rank Probability table : %s (%d treatments)\n", table_file, nrow(df_summary)))
  cat(sprintf(" - Serialized Rank data object   : %s\n", model_file))
  
  cat("\n [TREATMENT HIERARCHY & SUCRA AUDIT]\n")
  for (i in seq_len(nrow(df_summary))) {
    trt <- df_summary$Treatment[i]
    cat(sprintf("   %d. %-10s | SUCRA: %.3f | P(Rank 1): %5.1f%% | Mean Rank: %.2f\n",
                i, trt, df_summary$SUCRA[i], df_summary$Rank_1[i] * 100, df_summary$Mean_Rank[i]))
  }
}

cat(" [SUCCESS] Rank probabilities & SUCRA calculation completed cleanly.\n")


