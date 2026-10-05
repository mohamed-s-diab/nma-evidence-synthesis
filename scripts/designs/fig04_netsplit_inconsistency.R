# ==============================================================================
# Design Script: scripts/designs/fig04_netsplit_inconsistency.R
# Visual Target: Figure 4 - Node-Splitting Local Inconsistency Forest Plot
# Output File:   outputs/figures/04_netsplit_inconsistency.png (300 DPI Publication Figure)
# Framework:     netmeta (Uses Cached NMA Model)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
})

cat("\n======================================================================\n")
cat(" [DESIGN 04/12] FIGURE 04: NODE-SPLITTING LOCAL INCONSISTENCY FOREST PLOT\n")
cat("======================================================================\n")

# 1. Load Cached Model (Auto-fit if missing or data changed)
model_path <- "outputs/models/nma_model.rds"
data_path  <- "data/trial_contrasts.csv"

needs_refit <- !file.exists(model_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(model_path))

if (needs_refit) {
  cat(" - Dataset updated or cached model missing. Re-fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

load_start_time <- Sys.time()
nma <- readRDS(model_path)
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached model in %.3f seconds.\n", load_time_taken))

# 2. Calculate Node-Splitting Models
cat(" - Computing node-splitting models across all closed evidence loops ...\n")
ns <- netsplit(nma)

trt_labels_map <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

clean_comps <- function(comps, map) {
  sapply(comps, function(comp) {
    parts <- strsplit(comp, ":")[[1]]
    p1 <- ifelse(parts[1] %in% names(map), map[parts[1]], parts[1])
    p2 <- ifelse(parts[2] %in% names(map), map[parts[2]], parts[2])
    paste(p1, "vs", p2)
  })
}
ns$comparison <- clean_comps(ns$comparison, trt_labels_map)

# 3. Render Publication Node-Splitting Forest Plot (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/04_netsplit_inconsistency.png"
cat(sprintf(" - Rendering Figure 4 to: %s ...\n", output_fig))

# Full dimensions (3400x4600px) ensure zero truncation of loops, tests, and axis
png(output_fig, width = 3400, height = 4600, res = 300)

forest(
  ns,
  pooled = "random",
  fontsize = 9,
  spacing = 1.05,
  digits = 2,
  smlab = "Hazard Ratio (95% CI)\nDirect vs Indirect vs Network"
)

dev.off()

cat(sprintf(" [SUCCESS] Figure 4 rendered cleanly: %s\n\n", output_fig))
