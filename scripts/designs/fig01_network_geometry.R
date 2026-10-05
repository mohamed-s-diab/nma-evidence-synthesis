# ==============================================================================
# Design Script: scripts/designs/fig01_network_geometry.R
# Visual Target: Figure 1 - Evidence Network Geometry (Network Topology)
# Output File:   outputs/figures/01_network_geometry.png (300 DPI Publication Figure)
# Framework:     netmeta (Uses Cached NMA Model)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [DESIGN 01/12] FIGURE 01: EVIDENCE NETWORK GEOMETRY\n")
cat("======================================================================\n")

# 1. Load Cached Model (Auto-fit if missing or data changed)
model_path <- "outputs/models/nma_model.rds"
data_path  <- "data/nsclc_trial_contrasts.csv"

needs_refit <- !file.exists(model_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(model_path))

if (needs_refit) {
  cat(" - Dataset updated or cached model missing. Re-fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}
nma <- readRDS(model_path)
dat <- nma$data
cat(sprintf(" - Loaded model with %d treatments and %d comparisons.\n", nma$n, nma$m))

# 2. Node & Palette Configuration
colors_nodes <- c(
  "Drug A" = "#718096", # Slate Grey (Standard Reference)
  "Drug B" = "#3182CE", # Classic Blue
  "Drug C" = "#2B6CB0", # Deep Blue
  "Drug D" = "#805AD5", # Purple
  "Drug E" = "#D69E2E", # Warm Amber
  "Drug F" = "#DD6B20"  # Rust Orange
)

trt_labels_map <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

# Compute cumulative patient sample size per treatment node
pts_size <- sapply(nma$trts, function(t) {
  sum(dat$n_treat1[dat$treat1 == t], dat$n_treat2[dat$treat2 == t], na.rm = TRUE)
})
pts_cex <- 6.5 + (pts_size / max(pts_size)) * 4.5

# 3. Render Publication Network Geometry (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/01_network_geometry.png"
cat(sprintf(" - Rendering Figure 1 to: %s ...\n", output_fig))

png(output_fig, width = 3000, height = 2600, res = 300)
par(mar = c(5.2, 2.5, 3.8, 2.5))

netgraph(
  nma,
  labels = trt_labels_map[nma$trts],
  points = TRUE,
  cex.points = pts_cex,
  col.points = colors_nodes[nma$trts],
  col = "#718096",
  plastic = FALSE,
  thickness = "number.of.studies",
  lwd.max = 7.5,
  lwd.min = 2,
  cex = 1.3,
  offset = 0.045,
  multiarm = TRUE,
  col.multiarm = "#E2E8F0",
  main = "Evidence Network Geometry: Overall Survival (Multi-Treatment Trial Benchmark)"
)
mtext("Node diameter proportional to sample size | Line thickness proportional to trial count", 
      side = 3, line = 0.5, cex = 1.0, col = "#4A5568")

# Horizontal centered legend at bottom with optimized offset
legend("bottom", 
       legend = c("1 Trial", "2-3 Trials", "5+ Trials"), 
       lwd = c(2, 4.5, 7.5), 
       col = "#718096", 
       horiz = TRUE,
       bty = "o", 
       box.col = "#CBD5E0",
       bg = "#FFFFFFEE",
       title = "Direct Evidence Base (Line Thickness)", 
       cex = 0.95,
       inset = c(0, -0.045),
       xpd = TRUE)
dev.off()

cat(sprintf(" [SUCCESS] Figure 1 rendered cleanly: %s\n\n", output_fig))
