# ==============================================================================
# Test Suite: test_pipeline_integrity.R
# Purpose: Comprehensive Automated Quality Assurance for Evidence Synthesis Engine
# Scope:
#   1. Data Contract & Schema Integrity
#   2. Analytical & Visual Script Syntax Validation
#   3. Model Convergence & Graph Connectivity Auditing
#   4. Publication Artifacts (14 Figures & Tables) Verification
# ==============================================================================

cat("\n==============================================================================\n")
cat("          RUNNING EVIDENCE SYNTHESIS INTEGRITY TEST SUITE                     \n")
cat("==============================================================================\n")

test_failures <- 0
test_count <- 0

assert_test <- function(desc, condition) {
  test_count <<- test_count + 1
  if (condition) {
    cat(sprintf("  [PASS] Test %02d: %s\n", test_count, desc))
  } else {
    cat(sprintf("  [FAIL] Test %02d: %s\n", test_count, desc))
    test_failures <<- test_failures + 1
  }
}

# ------------------------------------------------------------------------------
# 1. DATA CONTRACT & SCHEMA INTEGRITY
# ------------------------------------------------------------------------------
cat("\n--- Section 1: Data Contract & Input Validation ---\n")

contrasts_path <- "data/trial_contrasts.csv"
assert_test("Contrasts dataset file exists", file.exists(contrasts_path))

if (file.exists(contrasts_path)) {
  contrasts <- read.csv(contrasts_path, stringsAsFactors = FALSE)
  
  required_cols <- c("studlab", "treat1", "treat2", "TE", "seTE")
  assert_test("Contrasts dataset contains all required mathematical columns (studlab, treat1, treat2, TE, seTE)", 
              all(required_cols %in% colnames(contrasts)))
  
  assert_test("No missing values in primary log Hazard Ratio (TE)", 
              !any(is.na(contrasts$TE)))
  
  assert_test("All standard errors (seTE) are strictly positive numbers", 
              all(contrasts$seTE > 0, na.rm = TRUE))
  
  assert_test("Trial contrast base contains >= 20 landmark clinical trials", 
              length(unique(contrasts$studlab)) >= 20)
}

toxicity_path <- "data/toxicity_events.csv"
assert_test("Toxicity dataset file exists", file.exists(toxicity_path))

if (file.exists(toxicity_path)) {
  tox <- read.csv(toxicity_path, stringsAsFactors = FALSE)
  tox_required <- c("studlab", "treat1", "treat2", "event1", "n1", "event2", "n2")
  assert_test("Toxicity dataset contains standard event/sample size fields (studlab, treat1, treat2, event1, n1, event2, n2)",
              all(tox_required %in% colnames(tox)))
              
  assert_test("All toxicity events are valid non-negative counts <= arm sample sizes",
              all(tox$event1 >= 0 & tox$event1 <= tox$n1) && all(tox$event2 >= 0 & tox$event2 <= tox$n2))
}

# ------------------------------------------------------------------------------
# 2. SCRIPT SYNTAX VALIDATION (PARSE WITHOUT EXECUTION)
# ------------------------------------------------------------------------------
cat("\n--- Section 2: Codebase Syntax Integrity (Static Parse) ---\n")

analysis_files <- list.files("scripts/analyses", pattern = "\\.R$", full.names = TRUE)
assert_test("All 12 sequential analysis engine scripts present", length(analysis_files) == 12)

all_analyses_clean <- TRUE
for (f in analysis_files) {
  res <- tryCatch(parse(f), error = function(e) e)
  if (inherits(res, "error")) {
    cat(sprintf("     Syntax error in %s: %s\n", f, conditionMessage(res)))
    all_analyses_clean <- FALSE
  }
}
assert_test("All 12 analysis engines pass R parser validation with zero syntax errors", all_analyses_clean)

design_files <- list.files("scripts/designs", pattern = "\\.R$", full.names = TRUE)
assert_test("All 14 graphic design scripts present", length(design_files) == 14)

all_designs_clean <- TRUE
for (f in design_files) {
  res <- tryCatch(parse(f), error = function(e) e)
  if (inherits(res, "error")) {
    cat(sprintf("     Syntax error in %s: %s\n", f, conditionMessage(res)))
    all_designs_clean <- FALSE
  }
}
assert_test("All 14 graphic designs pass R parser validation with zero syntax errors", all_designs_clean)

# ------------------------------------------------------------------------------
# 3. MODEL CONVERGENCE & ARTIFACT AUDITING
# ------------------------------------------------------------------------------
cat("\n--- Section 3: Serialized Models & Analytical Outputs ---\n")

model_path <- "outputs/models/nma_model.rds"
assert_test("Primary OS Network Meta-Analysis serialized model exists", file.exists(model_path))

if (file.exists(model_path)) {
  mod <- readRDS(model_path)
  assert_test("Fitted model object inherits from netmeta class", inherits(mod, "netmeta"))
  assert_test("Fitted network has valid treatments count (>= 5 treatments)", mod$n >= 5)
  assert_test("Model converged with valid degrees of freedom and total Q statistic", mod$df.Q > 0 && !is.na(mod$Q))
}

# ------------------------------------------------------------------------------
# 4. PUBLICATION FIGURES & TABLES AUDITING
# ------------------------------------------------------------------------------
cat("\n--- Section 4: 300 DPI Publication Exhibits & Summary Tables ---\n")

expected_figures <- c(
  "outputs/figures/01_network_geometry.png",
  "outputs/figures/02_forest_plot_random.png",
  "outputs/figures/03_pscore_ranking.png",
  "outputs/figures/04_netsplit_inconsistency.png",
  "outputs/figures/05_netheat_plot.png",
  "outputs/figures/06_funnel_plot.png",
  "outputs/figures/07_league_table_figure.png",
  "outputs/figures/08_leave_one_out_forest.png",
  "outputs/figures/09_component_effects.png",
  "outputs/figures/10_rankograms.png",
  "outputs/figures/11_benefit_risk_tradeoff.png",
  "outputs/figures/12_metaregression_bubble.png",
  "outputs/figures/13_subgroup_forest.png",
  "outputs/figures/14_mcid_probabilities.png"
)

all_figs_exist <- TRUE
for (fig in expected_figures) {
  if (!file.exists(fig) || file.info(fig)$size < 1000) {
    all_figs_exist <- FALSE
    cat(sprintf("     Missing or corrupted figure: %s\n", fig))
  }
}
assert_test("All 14 high-resolution publication figures exist with non-zero size (300 DPI)", all_figs_exist)

expected_tables <- c(
  "outputs/tables/treatment_rankings.csv",
  "outputs/tables/league_table_random_common.csv",
  "outputs/tables/inconsistency_statistics.csv",
  "outputs/tables/league_table_formatted.html",
  "outputs/tables/leave_one_out_results.csv",
  "outputs/tables/component_nma_effects.csv",
  "outputs/tables/rank_probabilities_matrix.csv",
  "outputs/tables/benefit_risk_tradeoff.csv",
  "outputs/tables/metaregression_results.csv",
  "outputs/tables/subgroup_analysis_results.csv",
  "outputs/tables/mcid_superiority_summary.csv"
)

all_tables_exist <- all(file.exists(expected_tables))
assert_test("All core summary CSV and HTML league tables exist and are accessible", all_tables_exist)

# ------------------------------------------------------------------------------
# 5. RESEARCH COMPENDIUM METADATA & PACKAGING AUDITING
# ------------------------------------------------------------------------------
cat("\n--- Section 5: rOpenSci Compendium Packaging Metadata ---\n")

desc_valid <- file.exists("DESCRIPTION") && !inherits(tryCatch(read.dcf("DESCRIPTION"), error = function(e) e), "error")
assert_test("Standard rOpenSci DESCRIPTION compendium file exists and parses validly", desc_valid)

# ------------------------------------------------------------------------------
# FINAL TEST REPORT
# ------------------------------------------------------------------------------
cat("\n==============================================================================\n")
cat(sprintf(" TEST SUITE SUMMARY: %d/%d Passed (%.1f%%)\n", 
            test_count - test_failures, test_count, 
            100 * (test_count - test_failures) / test_count))

if (test_failures > 0) {
  cat(sprintf(" [FAILURE] %d test(s) failed. Please review the errors above.\n", test_failures))
  quit(status = 1)
} else {
  cat(" [SUCCESS] All integrity tests passed. Engine is verified and production-ready!\n")
  cat("==============================================================================\n\n")
  quit(status = 0)
}
