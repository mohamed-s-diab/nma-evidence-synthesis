# ==============================================================================
# Script: scripts/analyses/07_component_nma.R
# Purpose: Additive & Interactive Component Network Meta-Analysis (CNMA)
# Methodology: Rücker et al. (2020) / Welton et al. (2009)
# Implementation: netmeta::netcomb() with graph-theoretical decomposition
# Deconstructs multi-agent regimens into constituent components:
#   - Component A [Reference Backbone Anchor]
#   - Component B
#   - Component C
#   - Component D
# Outputs: outputs/models/component_nma_data.rds
#          outputs/tables/component_nma_effects.csv
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [ANALYSIS 07/12] COMPONENT NETWORK META-ANALYSIS (CNMA)\n")
cat("======================================================================\n")

data_path   <- "data/trial_contrasts.csv"
model_file  <- "outputs/models/component_nma_data.rds"
table_file  <- "outputs/tables/component_nma_effects.csv"
script_file <- "scripts/analyses/07_component_nma.R"

if (!file.exists(data_path)) {
  stop(sprintf("Error: Contrast dataset not found at '%s'.", data_path))
}

force_refit <- (exists("force_refit") && isTRUE(force_refit))
data_mod    <- file.exists(model_file) && (file.mtime(data_path) > file.mtime(model_file))
script_mod  <- file.exists(model_file) && (file.mtime(script_file) > file.mtime(model_file))
cache_valid <- !force_refit && file.exists(model_file) && file.exists(table_file) && !data_mod && !script_mod

if (cache_valid) {
  cat(sprintf(" - Existing CNMA cache is up-to-date (Last modified: %s).\n", 
              as.character(file.mtime(model_file))))
  cat(" - Skipping redundant estimation. To force refit, set force_refit <- TRUE\n")
  cnma_data <- readRDS(model_file)
} else {
  cat(" - Deconstructing multi-agent combination regimens into active components ...\n")
  dat <- read.csv(data_path, stringsAsFactors = FALSE)

  # Pharmacologic Component Mapping
  # Component A is defined as the inactive backbone reference
  map_trt <- c(
    "Drug A" = "Component A",
    "Drug B" = "Component B",
    "Drug C" = "Component A + Component B",
    "Drug D" = "Component B + Component C",
    "Drug E" = "Component D",
    "Drug F" = "Component A + Component D"
  )

  dat$t1_comp <- unname(map_trt[dat$treat1])
  dat$t2_comp <- unname(map_trt[dat$treat2])

  # Fit standard NMA with component-mapped labels
  nma_comp <- netmeta(
    TE = TE,
    seTE = seTE,
    treat1 = t1_comp,
    treat2 = t2_comp,
    studlab = studlab,
    data = dat,
    sm = "HR",
    reference.group = "Component A",
    random = TRUE,
    common = TRUE,
    tol.multiarm = 0.005,
    details.chkmultiarm = FALSE
  )

  # Fit Component NMA (CNMA) with inactive reference = 'Component A'
  nc <- netcomb(nma_comp, inactive = "Component A")

  # Extract Component-Specific Incremental Effects
  # Comp.random is a vector of log-hazard ratios
  comp_names <- nc$comps
  comp_hr    <- exp(nc$Comp.random)
  comp_lower <- exp(nc$lower.Comp.random)
  comp_upper <- exp(nc$upper.Comp.random)
  comp_z     <- nc$statistic.Comp.random
  comp_p     <- nc$pval.Comp.random

  df_components <- data.frame(
    Type           = "Component",
    Item           = comp_names,
    Reference      = "Component A Backbone",
    iHR            = round(comp_hr, 3),
    CI_Lower       = round(comp_lower, 3),
    CI_Upper       = round(comp_upper, 3),
    HR_String      = sprintf("%.2f (%.2f-%.2f)", comp_hr, comp_lower, comp_upper),
    Z_Score        = round(comp_z, 2),
    P_Value        = comp_p,
    P_Value_String = ifelse(comp_p < 0.0001, "< 0.0001", sprintf("= %.4f", comp_p)),
    stringsAsFactors = FALSE
  )

  # Extract Full Regimen Combinations under Additive Model
  comb_trts   <- nc$trts[nc$trts != "Component A"]
  # In netcomb, treatment estimates vs reference:
  te_comb     <- nc$TE.random[comb_trts, "Component A"]
  low_comb    <- nc$lower.random[comb_trts, "Component A"]
  upp_comb    <- nc$upper.random[comb_trts, "Component A"]
  p_comb      <- nc$pval.random[comb_trts, "Component A"]

  df_combinations <- data.frame(
    Type           = "Combination (Additive Model)",
    Item           = comb_trts,
    Reference      = "Component A Backbone",
    iHR            = round(exp(te_comb), 3),
    CI_Lower       = round(exp(low_comb), 3),
    CI_Upper       = round(exp(upp_comb), 3),
    HR_String      = sprintf("%.2f (%.2f-%.2f)", exp(te_comb), exp(low_comb), exp(upp_comb)),
    Z_Score        = round((te_comb) / nc$seTE.random[comb_trts, "Component A"], 2),
    P_Value        = p_comb,
    P_Value_String = ifelse(p_comb < 0.0001, "< 0.0001", sprintf("= %.4f", p_comb)),
    stringsAsFactors = FALSE
  )

  # Combine and Format Table
  df_cnma_summary <- rbind(df_components, df_combinations)

  # Bundle Serialization Data
  cnma_data <- list(
    netcomb_obj     = nc,
    nma_comp_obj    = nma_comp,
    components_df   = df_components,
    combinations_df = df_combinations,
    summary_table   = df_cnma_summary,
    Q_additive      = nc$Q.additive,
    df_Q_additive   = nc$df.Q.additive,
    pval_Q_additive = nc$pval.Q.additive,
    Q_standard      = nc$Q.standard,
    df_Q_standard   = nc$df.Q.standard,
    pval_Q_standard = nc$pval.Q.standard,
    Q_diff          = nc$Q.diff,
    df_Q_diff       = nc$df.Q.diff,
    pval_Q_diff     = nc$pval.Q.diff
  )

  dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
  dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

  saveRDS(cnma_data, model_file)
  write.csv(df_cnma_summary, table_file, row.names = FALSE)

  cat(sprintf(" - Saved Component NMA table : %s (%d rows)\n", table_file, nrow(df_cnma_summary)))
  cat(sprintf(" - Serialized CNMA object     : %s\n", model_file))
}

# If loaded from cache, extract variables needed for the audit
if (cache_valid) {
  df_components <- cnma_data$components_df
  nc            <- cnma_data$netcomb_obj
}

cat("\n [COMPONENT NMA SCIENTIFIC AUDIT]\n")
cat(sprintf(" - Component B iHR : %.3f (95%% CI: %.3f - %.3f, p %s)\n",
            df_components$iHR[df_components$Item == "Component B"],
            df_components$CI_Lower[df_components$Item == "Component B"],
            df_components$CI_Upper[df_components$Item == "Component B"],
            df_components$P_Value_String[df_components$Item == "Component B"]))
cat(sprintf(" - Component D iHR : %.3f (95%% CI: %.3f - %.3f, p %s)\n",
            df_components$iHR[df_components$Item == "Component D"],
            df_components$CI_Lower[df_components$Item == "Component D"],
            df_components$CI_Upper[df_components$Item == "Component D"],
            df_components$P_Value_String[df_components$Item == "Component D"]))
cat(sprintf(" - Component C iHR : %.3f (95%% CI: %.3f - %.3f, p %s)\n",
            df_components$iHR[df_components$Item == "Component C"],
            df_components$CI_Lower[df_components$Item == "Component C"],
            df_components$CI_Upper[df_components$Item == "Component C"],
            df_components$P_Value_String[df_components$Item == "Component C"]))
cat(sprintf(" - Additivity vs Synergy Q_diff : %.2f (df = %d, p = %.4f)\n",
            nc$Q.diff, nc$df.Q.diff, nc$pval.Q.diff))

cat("\n [SUCCESS] Component NMA completed cleanly.\n")
