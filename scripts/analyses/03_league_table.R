# ==============================================================================
# Script: scripts/analyses/03_league_table.R
# Purpose: Pairwise Dual-Model League Table Generation (CSV Matrix)
# Inputs:  outputs/models/nma_model.rds & outputs/models/nma_rankings.rds
# Output:  outputs/tables/league_table_random_common.csv
# Package: netmeta (Rücker & Schwarzer)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 03/12] LEAGUE TABLE GENERATION (CSV MATRIX)\n")
cat("======================================================================\n")

# 1. Load Cached Model & Rankings (Auto-fit if missing or data changed)
model_path   <- "outputs/models/nma_model.rds"
ranking_path <- "outputs/models/nma_rankings.rds"
data_path    <- "data/trial_contrasts.csv"

needs_refit <- !file.exists(model_path) || !file.exists(ranking_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(model_path))

if (needs_refit) {
  cat(" - Data updated or cached model missing. Fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

load_start_time <- Sys.time()
nma <- readRDS(model_path)
rk <- readRDS(ranking_path)
trt_order <- names(sort(rk$ranking.random, decreasing = TRUE))
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached model & rankings in %.3f seconds.\n", load_time_taken))

# 2. Construct Dual-Model League Table
# Lower triangle: Random-effects model HR [95% CI]
# Upper triangle: Common-effects model HR [95% CI]
lg <- netleague(nma, digits = 2, seq = trt_order)

# 3. Export Raw CSV Matrix
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
output_csv <- "outputs/tables/league_table_random_common.csv"
write.csv(lg$random, output_csv)
cat(sprintf(" - Exported raw league matrix CSV to: %s\n\n", output_csv))
print(lg$random)
cat("\n")
