# ==============================================================================
# Design Script: scripts/designs/fig02_forest_plot.R
# Visual Target: Figure 2 - Reference Comparison Forest Plot vs Drug A
# Output File:   outputs/figures/02_forest_plot_random.png (300 DPI Publication Figure)
# Framework:     netmeta (Uses Cached NMA Model & Hierarchy)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [DESIGN 02/12] FIGURE 02: REFERENCE FOREST PLOT VS DRUG A\n")
cat("======================================================================\n")

# 1. Load Cached Model & Rankings (Auto-fit if missing or data changed)
model_path   <- "outputs/models/nma_model.rds"
ranking_path <- "outputs/models/nma_rankings.rds"
data_path    <- "data/trial_contrasts.csv"

needs_refit <- !file.exists(model_path) || !file.exists(ranking_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(model_path))

if (needs_refit) {
  cat(" - Dataset updated or cached model missing. Re-fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

load_start_time <- Sys.time()
nma <- readRDS(model_path)
rk <- readRDS(ranking_path)
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached model & rankings in %.3f seconds.\n", load_time_taken))

trt_labels_map <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

# 2. Render Publication Forest Plot (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/02_forest_plot_random.png"
cat(sprintf(" - Rendering Figure 2 to: %s ...\n", output_fig))

png(output_fig, width = 3200, height = 1800, res = 300)

forest(
  nma,
  labels = trt_labels_map[nma$trts],
  reference.group = "Drug A",
  pooled = "random",
  sortvar = -rk$ranking.random,
  smlab = "Hazard Ratio (95% CI)\nvs Drug A",
  label.left = "Favors Active Regimen",
  label.right = "Favors Drug A",
  drop.reference.group = TRUE,
  digits = 2,
  col.square = "#2B6CB0",
  col.diamond = "#C53030",
  col.inside = "#1A202C",
  header.line = TRUE,
  leftcols = c("studlab"),
  leftlabs = c("Treatment Regimen"),
  rightcols = c("effect", "ci"),
  rightlabs = c("HR", "95% CI")
)

dev.off()

cat(sprintf(" [SUCCESS] Figure 2 rendered cleanly: %s\n\n", output_fig))
