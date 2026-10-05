# ==============================================================================
# Script: scripts/analyses/02_treatment_rankings.R
# Purpose: Treatment Hierarchy & P-Score Calculations (Frequentist SUCRA)
# Inputs:  outputs/models/nma_model.rds & outputs/models/nma_rankings.rds
# Output:  outputs/tables/treatment_rankings.csv
# Package: netmeta
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 02/12] TREATMENT RANKING VIA P-SCORES (SUCRA ANALOGUE)\n")
cat("======================================================================\n")

# 1. Load Cached Model & Rankings (Auto-fit if missing or data changed)
model_path   <- "outputs/models/nma_model.rds"
ranking_path <- "outputs/models/nma_rankings.rds"
data_path    <- "data/nsclc_trial_contrasts.csv"

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
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Successfully loaded cached model & rankings in %.3f seconds.\n", load_time_taken))

# 2. Extract P-Scores & Treatment Hierarchy
pscores_rand <- rk$ranking.random
trt_order <- names(sort(pscores_rand, decreasing = TRUE))

trt_labels_map <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

# 3. Construct Comprehensive Treatment Ranking Table
df_rankings <- data.frame(
  Treatment = trt_labels_map[trt_order],
  Code = trt_order,
  Rank = 1:length(trt_order),
  Pscore_Random = round(pscores_rand[trt_order], 4),
  Pscore_Common = round(rk$ranking.common[trt_order], 4),
  HR_vs_Ref_Random = ifelse(trt_order == "Drug A", "1.00 (Reference)",
                            sprintf("%.2f [%.2f; %.2f]", 
                                    exp(nma$TE.random[trt_order, "Drug A"]),
                                    exp(nma$lower.random[trt_order, "Drug A"]),
                                    exp(nma$upper.random[trt_order, "Drug A"]))),
  Pval_vs_Ref = ifelse(trt_order == "Drug A", "Reference",
                       ifelse(nma$pval.random[trt_order, "Drug A"] < 0.0001, "< 0.0001",
                              sprintf("%.4f", nma$pval.random[trt_order, "Drug A"]))),
  stringsAsFactors = FALSE
)

# 4. Export Ranking Table to CSV
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
output_tbl <- "outputs/tables/treatment_rankings.csv"
write.csv(df_rankings[, c("Treatment", "Rank", "Pscore_Random", "Pscore_Common", "HR_vs_Ref_Random", "Pval_vs_Ref")], 
          output_tbl, row.names = FALSE)

cat(sprintf(" - Successfully exported ranking table to: %s\n\n", output_tbl))
print(df_rankings[, c("Treatment", "Rank", "Pscore_Random", "HR_vs_Ref_Random", "Pval_vs_Ref")])
cat("\n")
