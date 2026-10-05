# ==============================================================================
# Script: run_all_pipeline.R
# Purpose: Master Orchestrator for All 12 NMA Analyses & 14 Publication Figure Designs
# Architecture:
#   - Phase 1: Statistical Analyses & Table Generation (scripts/analyses/ 01 to 12)
#   - Phase 2: Publication Figure Designs (scripts/designs/ fig01 to fig14)
# Execution: Rscript scripts/run_all_pipeline.R
# ==============================================================================

cat("\n==============================================================================\n")
cat("          MASTER NETWORK META-ANALYSIS PRODUCTION PIPELINE                    \n")
cat("          Multi-Treatment Evidence Synthesis Research Compendium              \n")
cat("          Reproducible Methodology: 12 Analytical Modules | 14 Exhibits       \n")
cat("==============================================================================\n")

start_time <- Sys.time()

# 0. Ensure required datasets exist
if (!file.exists("data/nsclc_trial_contrasts.csv")) {
  stop("Error: Contrast dataset 'data/nsclc_trial_contrasts.csv' not found. Please ensure the data file exists before running the pipeline.")
}
if (!file.exists("data/nsclc_toxicity_events.csv")) {
  stop("Error: Toxicity dataset 'data/nsclc_toxicity_events.csv' not found. Please ensure the data file exists before running the pipeline.")
}

# ------------------------------------------------------------------------------
# PHASE 1: STATISTICAL ANALYSES & TABLE GENERATION (12 ENGINES)
# ------------------------------------------------------------------------------
cat("\n==============================================================================\n")
cat(" >>> PHASE 1: STATISTICAL ANALYSES & SUMMARY TABLES (scripts/analyses/)        \n")
cat("==============================================================================\n")

analysis_modules <- list(
  list(file = "scripts/analyses/01_fit_nma_model.R",             name = "Model Estimation & Graph-Theoretical Fit"),
  list(file = "scripts/analyses/02_treatment_rankings.R",        name = "Treatment Hierarchy & P-Scores"),
  list(file = "scripts/analyses/03_league_table.R",              name = "Dual-Model League Table (CSV Matrix)"),
  list(file = "scripts/analyses/04_inconsistency_tests.R",       name = "Global Q Decomposition & Inconsistency Table"),
  list(file = "scripts/analyses/05_league_table_html.R",         name = "Formatted Interactive HTML League Table"),
  list(file = "scripts/analyses/06_leave_one_out_sensitivity.R", name = "Leave-One-Out (LOO) Influence & Sensitivity Cross-Validation"),
  list(file = "scripts/analyses/07_component_nma.R",              name = "Additive & Interactive Component NMA (CNMA)"),
  list(file = "scripts/analyses/08_rank_probabilities.R",         name = "10,000 Monte Carlo Probabilistic Hierarchy & SUCRA"),
  list(file = "scripts/analyses/09_benefit_risk_tradeoff.R",      name = "Dual Efficacy vs Grade 3-5 Severe Toxicity NMA"),
  list(file = "scripts/analyses/10_network_metaregression.R",     name = "Network Meta-Regression & Transitivity Diagnostics"),
  list(file = "scripts/analyses/11_subgroup_analysis.R",          name = "Subgroup NMA: Asia-Pacific vs Global Evidence (Q_bws Interaction)"),
  list(file = "scripts/analyses/12_mcid_analysis.R",              name = "Minimal Clinically Important Difference (MCID) Decision Framework Engine")
)

for (idx in seq_along(analysis_modules)) {
  mod <- analysis_modules[[idx]]
  cat(sprintf("\n[ANALYSIS %02d/%02d]: %s (%s) ...\n", idx, length(analysis_modules), mod$name, mod$file))
  t0 <- Sys.time()
  
  env <- new.env(parent = globalenv())
  source(mod$file, local = env)
  
  t1 <- Sys.time()
  cat(sprintf(">>> Analysis %02d finished in %.2f seconds.\n", idx, as.numeric(difftime(t1, t0, units = "secs"))))
}

# ------------------------------------------------------------------------------
# PHASE 2: PUBLICATION GRAPHIC DESIGNS (14 FIGURES AT 300 DPI)
# ------------------------------------------------------------------------------
cat("\n==============================================================================\n")
cat(" >>> PHASE 2: PUBLICATION GRAPHIC DESIGNS (300 DPI) (scripts/designs/)        \n")
cat("==============================================================================\n")

design_modules <- list(
  list(file = "scripts/designs/fig01_network_geometry.R",       name = "Figure 01: Evidence Network Geometry (Topology)"),
  list(file = "scripts/designs/fig02_forest_plot.R",            name = "Figure 02: Reference Forest Plot vs Drug A"),
  list(file = "scripts/designs/fig03_pscore_ranking.R",         name = "Figure 03: P-Score Treatment Ranking Hierarchy"),
  list(file = "scripts/designs/fig04_netsplit_inconsistency.R",   name = "Figure 04: Node-Splitting Local Inconsistency Forest Plot"),
  list(file = "scripts/designs/fig05_netheat_plot.R",           name = "Figure 05: Net Heat Inconsistency Matrix Plot"),
  list(file = "scripts/designs/fig06_funnel_plot.R",            name = "Figure 06: Comparison-Adjusted Funnel Plot & Egger Test"),
  list(file = "scripts/designs/fig07_league_table_matrix.R",    name = "Figure 07: Publication League Table Graphic Matrix"),
  list(file = "scripts/designs/fig08_leave_one_out_forest.R",   name = "Figure 08: Leave-One-Out Cross-Validation Sensitivity Forest"),
  list(file = "scripts/designs/fig09_component_effects.R",      name = "Figure 09: Component Network Meta-Analysis (CNMA) Forest"),
  list(file = "scripts/designs/fig10_rankograms.R",             name = "Figure 10: Probabilistic Hierarchy & Cumulative Rankograms"),
  list(file = "scripts/designs/fig11_benefit_risk_tradeoff.R",  name = "Figure 11: Bi-dimensional Benefit-Risk Trade-Off Matrix"),
  list(file = "scripts/designs/fig12_metaregression_bubble.R",  name = "Figure 12: Network Meta-Regression Bubble & Transitivity Plot"),
  list(file = "scripts/designs/fig13_subgroup_forest.R",        name = "Figure 13: Subgroup Comparative Forest Plot (Asia-Pacific vs Global)"),
  list(file = "scripts/designs/fig14_mcid_probabilities.R",     name = "Figure 14: MCID Clinical Superiority Decision Framework (HR <= 0.80)")
)

for (idx in seq_along(design_modules)) {
  mod <- design_modules[[idx]]
  cat(sprintf("\n[DESIGN %02d/%02d]: %s (%s) ...\n", idx, length(design_modules), mod$name, mod$file))
  t0 <- Sys.time()
  
  env <- new.env(parent = globalenv())
  source(mod$file, local = env)
  
  t1 <- Sys.time()
  cat(sprintf(">>> Design %02d finished in %.2f seconds.\n", idx, as.numeric(difftime(t1, t0, units = "secs"))))
}

total_elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

cat("\n==============================================================================\n")
cat(sprintf(" [PIPELINE SUCCESS] All %d analyses and %d figure designs generated in %.2f seconds!\n", 
            length(analysis_modules), length(design_modules), total_elapsed))
cat(" Outputs Directory Audit:\n")
cat(sprintf("  - Figures: outputs/figures/ (%d publication-grade 300 DPI figures, Fig 01 to %02d)\n",
            length(design_modules), length(design_modules)))
cat("  - Tables:  outputs/tables/  (Summary CSVs + Formatted Interactive HTML Table)\n")
cat("  - Models:  outputs/models/  (Serialized .rds cache objects for lightning-fast downstream builds)\n")
cat("==============================================================================\n\n")
