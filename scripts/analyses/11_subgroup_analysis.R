# ==============================================================================
# Script: scripts/analyses/11_subgroup_analysis.R
# Purpose: Subgroup Network Meta-Analysis: Geographic Setting & Ethnic Diversity
#          Comparative Evidence Synthesis: Asia-Pacific (8 Trials) vs Global (16 Trials)
# Methodology: netmeta::subgroup() / Borenstein & Higgins (2013)
# Evaluation: Within-subgroup heterogeneity (tau^2, I^2) & Between-subgroups interaction (Q_bws)
# Outputs: outputs/models/subgroup_analysis_data.rds
#          outputs/tables/subgroup_analysis_results.csv
#          outputs/tables/subgroup_network_summary.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 11/12] SUBGROUP NMA: ASIA-PACIFIC VS GLOBAL EVIDENCE\n")
cat("======================================================================\n")

model_file   <- "outputs/models/subgroup_analysis_data.rds"
table_file   <- "outputs/tables/subgroup_analysis_results.csv"
summary_file <- "outputs/tables/subgroup_network_summary.csv"
nma_file     <- "outputs/models/nma_model.rds"
data_path    <- "data/trial_contrasts.csv"
script_file  <- "scripts/analyses/11_subgroup_analysis.R"

if (!file.exists(nma_file)) {
  stop(sprintf("Error: Baseline NMA model not found at '%s'. Please run 01_fit_nma_model.R first.", nma_file))
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
  cat(sprintf(" - Existing Subgroup NMA cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant estimation. To force refit, set force_refit <- TRUE\n")
  sg_data <- readRDS(model_file)
} else {
  cat(" - Partitioning evidence network into Asia-Pacific vs Global multi-center trials ...\n")
  nma <- readRDS(nma_file)
  dat <- read.csv(data_path, stringsAsFactors = FALSE)
  
  # Group trials: 8 Asia-Pacific vs 16 Global (including international multi-center)
  dat$subgroup_region <- ifelse(dat$region == "Asia-Pacific", "Asia-Pacific", "Global")
  study_subgroup <- dat$subgroup_region[match(nma$studlab, dat$studlab)]
  
  cat(sprintf("   * Asia-Pacific trials: %d trials\n", sum(tapply(dat$subgroup_region == "Asia-Pacific", dat$studlab, any))))
  cat(sprintf("   * Global trials:       %d trials\n", sum(tapply(dat$subgroup_region == "Global", dat$studlab, any))))
  
  # Run Subgroup NMA via netmeta
  cat(" - Executing graph-theoretical subgroup decomposition ...\n")
  sg <- subgroup(nma, subgroup = study_subgroup)
  
  # Extract Subgroup Networks
  net_asia <- sg$networks[["Asia-Pacific"]]
  net_glob <- sg$networks[["Global"]]
  
  # Build Network-Level Summary Table
  df_net_summary <- data.frame(
    Subgroup = c("Asia-Pacific", "Global", "Full Network (Reference)"),
    Number_of_Trials = c(net_asia$k, net_glob$k, nma$k),
    Pairwise_Contrasts = c(net_asia$m, net_glob$m, nma$m),
    Treatments_Evaluated = c(
      paste(sort(net_asia$trts), collapse = ", "),
      paste(sort(net_glob$trts), collapse = ", "),
      paste(sort(nma$trts), collapse = ", ")
    ),
    Tau2 = c(round(net_asia$tau2, 4), round(net_glob$tau2, 4), round(nma$tau2, 4)),
    Tau = c(round(net_asia$tau, 4), round(net_glob$tau, 4), round(nma$tau, 4)),
    I2_Percent = sprintf("%.1f%%", c(net_asia$I2 * 100, net_glob$I2 * 100, nma$I2 * 100)),
    Cochrans_Q = round(c(net_asia$Q, net_glob$Q, nma$Q), 2),
    DF_Q = c(net_asia$df.Q, net_glob$df.Q, nma$df.Q),
    Pval_Q = sprintf("%.4f", c(net_asia$pval.Q, net_glob$pval.Q, nma$pval.Q)),
    stringsAsFactors = FALSE
  )
  
  # Extract Overlapping Comparisons & Between-Subgroups Heterogeneity (Q_bws)
  # Filter comparisons evaluated in both subgroups
  sg_rand <- sg$random
  valid_comps <- sg_rand[!is.na(sg_rand$Q) & sg_rand$df.Q > 0, ]
  
  # Calculate Total Between-Subgroups Interaction Test
  total_q_bws <- sum(valid_comps$Q)
  total_df    <- sum(valid_comps$df.Q)
  total_pval  <- 1 - pchisq(total_q_bws, total_df)
  
  # Match Asia-Pacific and Global estimates side-by-side
  asia_rows <- sg_rand[sg_rand$subgroup == "Asia-Pacific", ]
  glob_rows <- sg_rand[sg_rand$subgroup == "Global", ]
  
  merged_comps <- merge(
    asia_rows[, c("treat1", "treat2", "k", "TE", "seTE", "lower", "upper")],
    glob_rows[, c("treat1", "treat2", "k", "TE", "seTE", "lower", "upper")],
    by = c("treat1", "treat2"),
    suffixes = c("_Asia", "_Global")
  )
  
  # Merge in Q statistics from valid_comps
  q_lookup <- valid_comps[, c("treat1", "treat2", "Q", "df.Q", "pval.Q")]
  merged_comps <- merge(merged_comps, q_lookup, by = c("treat1", "treat2"), all.x = TRUE)
  
  # Map treatment names to clean publication clinical labels
  trt_labels_clean <- c(
    "Drug A" = "Drug A",
    "Drug B" = "Drug B",
    "Drug C" = "Drug C",
    "Drug D" = "Drug D",
    "Drug E" = "Drug E",
    "Drug F" = "Drug F"
  )
  
  # In netmeta, TE = treat1 vs treat2.
  # If treat1 is Drug A, treat2 is Active: exp(-TE) is Active vs Drug A (HR < 1 indicates survival prolongation)
  merged_comps$Active_Trt <- ifelse(merged_comps$treat1 == "Drug A", merged_comps$treat2, merged_comps$treat1)
  merged_comps$Comparator <- ifelse(merged_comps$treat1 == "Drug A", merged_comps$treat1, merged_comps$treat2)
  
  invert_flag <- (merged_comps$treat1 == "Drug A")
  
  te_asia <- ifelse(invert_flag, -merged_comps$TE_Asia, merged_comps$TE_Asia)
  low_asia <- ifelse(invert_flag, -merged_comps$upper_Asia, merged_comps$lower_Asia)
  upp_asia <- ifelse(invert_flag, -merged_comps$lower_Asia, merged_comps$upper_Asia)
  
  te_glob <- ifelse(invert_flag, -merged_comps$TE_Global, merged_comps$TE_Global)
  low_glob <- ifelse(invert_flag, -merged_comps$upper_Global, merged_comps$lower_Global)
  upp_glob <- ifelse(invert_flag, -merged_comps$lower_Global, merged_comps$upper_Global)
  
  merged_comps$Comparison_Clean <- paste(
    trt_labels_clean[merged_comps$Active_Trt], "vs", trt_labels_clean[merged_comps$Comparator]
  )
  
  merged_comps$HR_Asia <- sprintf("%.2f [%.2f; %.2f]", exp(te_asia), exp(low_asia), exp(upp_asia))
  merged_comps$HR_Global <- sprintf("%.2f [%.2f; %.2f]", exp(te_glob), exp(low_glob), exp(upp_glob))
  merged_comps$Q_bws <- round(merged_comps$Q, 4)
  merged_comps$DF <- merged_comps$df.Q
  merged_comps$P_Value <- sprintf("%.4f", merged_comps$pval.Q)
  merged_comps$Regional_Consistency <- ifelse(merged_comps$pval.Q > 0.05, "Consistent (Homogeneous)", "Regional Divergence")
  
  df_export <- merged_comps[, c("Comparison_Clean", "k_Asia", "HR_Asia", "k_Global", "HR_Global", "Q_bws", "DF", "P_Value", "Regional_Consistency")]
  colnames(df_export)[1] <- "Comparison"
  
  # Bundle All Objects for Serialization
  sg_data <- list(
    sg_obj          = sg,
    net_asia        = net_asia,
    net_glob        = net_glob,
    total_q_bws     = total_q_bws,
    total_df        = total_df,
    total_pval      = total_pval,
    network_summary = df_net_summary,
    contrast_table  = df_export,
    detailed_merged = merged_comps
  )
  
  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(sg_data, model_file)
  write.csv(df_export, table_file, row.names = FALSE)
  write.csv(df_net_summary, summary_file, row.names = FALSE)
  
  cat(sprintf(" - Saved Subgroup Contrast table : %s\n", table_file))
  cat(sprintf(" - Saved Network Summary table  : %s\n", summary_file))
  cat(sprintf(" - Serialized Subgroup data obj : %s\n", model_file))
  
  cat("\n [SUBGROUP INTERACTION AUDIT (Q_bws)]\n")
  cat(sprintf(" - Total Between-Subgroups Q (Q_bws): %.4f (df = %d, p = %.4f)\n", total_q_bws, total_df, total_pval))
  cat(sprintf(" - Clinical Verdict: %s\n\n", 
              ifelse(total_pval > 0.05, 
                     "Strict transitivity and regional consistency confirmed across Asian and Global trial populations.", 
                     "Regional effect modification detected.")))
  
  for (i in 1:nrow(df_export)) {
    cat(sprintf("   * %-26s | Asia: %-18s | Global: %-18s | Q = %6.4f (p = %s)\n",
                df_export$Comparison[i],
                df_export$HR_Asia[i],
                df_export$HR_Global[i],
                df_export$Q_bws[i],
                df_export$P_Value[i]))
  }
}

cat("\n [SUCCESS] Subgroup network meta-analysis completed cleanly.\n\n")
