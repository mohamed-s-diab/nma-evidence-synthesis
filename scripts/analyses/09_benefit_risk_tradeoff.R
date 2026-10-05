# ==============================================================================
# Script: scripts/analyses/09_benefit_risk_tradeoff.R
# Purpose: Bi-dimensional Benefit-Risk Trade-Off Engine (OS Efficacy vs Grade 3-5 Toxicity)
# Methodology: Dual Network Meta-Analyses (Survival HR vs Severe Toxicity Odds Ratio)
# Outputs: outputs/models/benefit_risk_data.rds
#          outputs/tables/benefit_risk_tradeoff.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 09/12] BI-DIMENSIONAL BENEFIT-RISK TRADE-OFF MATRIX\n")
cat("======================================================================\n")

data_path    <- "data/toxicity_events.csv"
model_file   <- "outputs/models/benefit_risk_data.rds"
table_file   <- "outputs/tables/benefit_risk_tradeoff.csv"
nma_os_file  <- "outputs/models/nma_model.rds"
rank_file    <- "outputs/models/rank_probabilities_data.rds"
script_file  <- "scripts/analyses/09_benefit_risk_tradeoff.R"

if (!file.exists(data_path)) {
  stop(sprintf("Error: Toxicity event dataset not found at '%s'.", data_path))
}
if (!file.exists(nma_os_file)) {
  stop(sprintf("Error: Baseline OS NMA model not found at '%s'.", nma_os_file))
}

force_refit <- (exists("force_refit") && isTRUE(force_refit))
data_mod    <- file.exists(model_file) && (file.mtime(data_path) > file.mtime(model_file))
os_mod      <- file.exists(model_file) && (file.mtime(nma_os_file) > file.mtime(model_file))
script_mod  <- file.exists(model_file) && (file.mtime(script_file) > file.mtime(model_file))
cache_valid <- !force_refit && file.exists(model_file) && file.exists(table_file) && !data_mod && !os_mod && !script_mod

if (cache_valid) {
  cat(sprintf(" - Existing Benefit-Risk cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant estimation. To force refit, set force_refit <- TRUE\n")
  br_data <- readRDS(model_file)
} else {
  cat(sprintf(" - Loading Grade 3-5 toxicity events from '%s' ...\n", data_path))
  df_tox <- read.csv(data_path, stringsAsFactors = FALSE)
  cat(sprintf(" - Loaded %d pairwise toxicity contrasts across %d trials.\n",
              nrow(df_tox), length(unique(df_tox$studlab))))
  
  # Calculate pairwise odds ratios
  pw_tox <- pairwise(
    treat = list(treat1, treat2),
    event = list(event1, event2),
    n = list(n1, n2),
    data = df_tox,
    studlab = studlab,
    sm = "OR"
  )
  
  cat(" - Fitting Safety NMA Model for Grade 3-5 Adverse Events ...\n")
  nma_tox <- netmeta(
    TE = TE, seTE = seTE,
    treat1 = treat1, treat2 = treat2,
    studlab = studlab, data = pw_tox,
    sm = "OR", reference.group = "Drug A",
    random = TRUE, common = TRUE,
    tol.multiarm = 0.005, details.chkmultiarm = FALSE
  )
  
  # Rank Safety (lower toxicity is better, small.values = 'good')
  rk_tox <- netrank(nma_tox, small.values = "good")
  
  # Load OS Baseline Model & Hierarchy
  nma_os <- readRDS(nma_os_file)
  
  # Extract Regimen-Specific Estimates vs Drug A
  trts <- nma_os$trts
  
  df_br <- data.frame(
    Treatment   = trts,
    # OS Efficacy Estimates (HR vs Drug A)
    HR_OS       = round(exp(nma_os$TE.random[trts, "Drug A"]), 3),
    HR_OS_Lower = round(exp(nma_os$lower.random[trts, "Drug A"]), 3),
    HR_OS_Upper = round(exp(nma_os$upper.random[trts, "Drug A"]), 3),
    Pval_OS     = nma_os$pval.random[trts, "Drug A"],
    
    # Severe Toxicity Estimates (OR vs Drug A)
    OR_Tox      = round(exp(nma_tox$TE.random[trts, "Drug A"]), 3),
    OR_Tox_Lower= round(exp(nma_tox$lower.random[trts, "Drug A"]), 3),
    OR_Tox_Upper= round(exp(nma_tox$upper.random[trts, "Drug A"]), 3),
    Pval_Tox    = nma_tox$pval.random[trts, "Drug A"],
    
    # SUCRA Metrics
    SUCRA_Safety   = round(rk_tox$ranking.random[trts], 3),
    stringsAsFactors = FALSE
  )
  
  # Reference adjustments for Drug A
  df_br$HR_OS[df_br$Treatment == "Drug A"]       <- 1.000
  df_br$HR_OS_Lower[df_br$Treatment == "Drug A"] <- 1.000
  df_br$HR_OS_Upper[df_br$Treatment == "Drug A"] <- 1.000
  df_br$OR_Tox[df_br$Treatment == "Drug A"]       <- 1.000
  df_br$OR_Tox_Lower[df_br$Treatment == "Drug A"] <- 1.000
  df_br$OR_Tox_Upper[df_br$Treatment == "Drug A"] <- 1.000
  
  # Add OS SUCRA
  if (file.exists(rank_file)) {
    rk_os <- readRDS(rank_file)
    df_br$SUCRA_Efficacy <- round(rk_os$sucra_scores[df_br$Treatment], 3)
  } else {
    rk_os <- netrank(nma_os, small.values = "good")
    df_br$SUCRA_Efficacy <- round(rk_os$ranking.random[df_br$Treatment], 3)
  }
  
  # Clinical Benefit-Risk Quadrant Classification
  # Median thresholds: HR_OS < 0.80 = High Efficacy; OR_Tox < 1.00 = Favorable Safety
  df_br$Quadrant <- with(df_br, ifelse(
    HR_OS < 0.80 & OR_Tox <= 1.00, "Ideal Profile (High Efficacy, Low Toxicity)",
    ifelse(HR_OS < 0.80 & OR_Tox > 1.00, "Intensive Efficacy (High Efficacy, Higher Toxicity)",
    ifelse(HR_OS >= 0.80 & OR_Tox <= 1.00, "Favorable Tolerability (Low Efficacy, Low Toxicity)",
           "Suboptimal (Low Efficacy, High Toxicity)"))
  ))
  
  # Net Clinical Benefit Index = SUCRA_Efficacy + SUCRA_Safety
  df_br$Net_Benefit_Score <- round(df_br$SUCRA_Efficacy + df_br$SUCRA_Safety, 3)
  df_br <- df_br[order(-df_br$Net_Benefit_Score), ]
  
  br_data <- list(
    nma_tox_obj    = nma_tox,
    rk_tox_obj     = rk_tox,
    df_tox_trials  = df_tox,
    benefit_risk_df= df_br
  )
  
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(br_data, model_file)
  write.csv(df_br, table_file, row.names = FALSE)
  
  cat(sprintf(" - Saved Benefit-Risk table : %s (%d treatments)\n", table_file, nrow(df_br)))
  cat(sprintf(" - Serialized BR data object : %s\n", model_file))
  
  cat("\n [BENEFIT-RISK DECISION MATRIX AUDIT]\n")
  for (i in 1:nrow(df_br)) {
    cat(sprintf("   * %-10s | OS HR: %.2f (%.2f-%.2f) | Tox OR: %.2f (%.2f-%.2f) | Net Score: %.2f | %s\n",
                df_br$Treatment[i],
                df_br$HR_OS[i], df_br$HR_OS_Lower[i], df_br$HR_OS_Upper[i],
                df_br$OR_Tox[i], df_br$OR_Tox_Lower[i], df_br$OR_Tox_Upper[i],
                df_br$Net_Benefit_Score[i], df_br$Quadrant[i]))
  }
}

cat(" [SUCCESS] Benefit-risk analysis completed cleanly.\n")
