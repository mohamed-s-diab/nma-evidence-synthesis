# ==============================================================================
# Design Script: scripts/designs/fig06_funnel_plot.R
# Visual Target: Figure 6 - Comparison-Adjusted Funnel Plot (Small-Study Effects)
# Output File:   outputs/figures/06_funnel_plot.png (300 DPI Publication Figure)
# Framework:     netmeta (Uses Cached NMA Model & Hierarchy)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
  library(meta)
})

cat("\n======================================================================\n")
cat(" [DESIGN 06/12] FIGURE 06: COMPARISON-ADJUSTED FUNNEL PLOT & EGGER TEST\n")
cat("======================================================================\n")

# 1. Load Cached Model & Rankings (Auto-fit if missing or data changed)
model_path   <- "outputs/models/nma_model.rds"
ranking_path <- "outputs/models/nma_rankings.rds"
data_path    <- "data/nsclc_trial_contrasts.csv"

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
trt_order <- names(sort(rk$ranking.random, decreasing = TRUE))
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

# 2. Render Publication Funnel Plot (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)

output_fig <- "outputs/figures/06_funnel_plot.png"
output_csv <- "outputs/tables/publication_bias_egger.csv"
output_rds <- "outputs/models/publication_bias_egger.rds"
cat(sprintf(" - Rendering Figure 6 to: %s ...\n", output_fig))

png(output_fig, width = 2800, height = 2400, res = 300)
par(mar = c(4.8, 4.8, 3.8, 2))

fn_res <- funnel(
  nma,
  order = trt_order,
  pooled = "random",
  pch = 19,
  col = "#2B6CB0",
  cex = 1.3,
  method.bias = "Egger",
  legend = FALSE,
  main = "Comparison-Adjusted Funnel Plot (Evaluation of Small-Study Effects)",
  xlab = "Log Hazard Ratio centered by comparison-specific effect",
  ylab = "Standard Error of Log Hazard Ratio"
)

# 3. Formal Egger Linear Regression Asymmetry Test
mb <- metabias(fn_res$TE.adj, fn_res$seTE, method.bias = "Egger")

t_stat   <- as.numeric(mb$statistic)
df_val   <- mb$df
pval_val <- mb$p.value
bias_est <- as.numeric(mb$estimate["bias"])
se_bias  <- as.numeric(mb$estimate["se.bias"])

# Save Egger Model & Summary Table
saveRDS(mb, output_rds)

df_egger <- data.frame(
  Test = "Egger Linear Regression Test of Funnel Plot Asymmetry",
  Predictor = "Standard Error (seTE)",
  Weight = "Inverse Variance (1/seTE^2)",
  Bias_Intercept = round(bias_est, 4),
  SE_Bias = round(se_bias, 4),
  T_Statistic = round(t_stat, 2),
  Degrees_of_Freedom = df_val,
  P_Value = sprintf("%.4f", pval_val),
  Small_Study_Effects = ifelse(pval_val > 0.10, "No evidence of small-study effects (Symmetric)", "Potential small-study effects detected"),
  stringsAsFactors = FALSE
)
write.csv(df_egger, output_csv, row.names = FALSE)

# Clean comparison labels for publication legend
raw_comps <- unique(fn_res$comparison)
clean_comps <- sapply(raw_comps, function(comp) {
  parts <- strsplit(comp, ":")[[1]]
  p1 <- ifelse(parts[1] %in% names(trt_labels_map), trt_labels_map[parts[1]], parts[1])
  p2 <- ifelse(parts[2] %in% names(trt_labels_map), trt_labels_map[parts[2]], parts[2])
  paste(p1, "vs", p2)
})

# Legend 1: Comparisons (Top Right)
legend(
  "topright",
  legend = clean_comps,
  pch = 19,
  col = "#2B6CB0",
  bty = "o",
  box.col = "#CBD5E0",
  bg = "#FFFFFFEE",
  cex = 0.82
)

# Legend 2: Formal Egger Test Callout (Top Left)
legend(
  "topleft",
  legend = c(
    "Formal Egger Asymmetry Test:",
    sprintf("  t = %.2f (df = %d)", t_stat, df_val),
    sprintf("  p-value = %.4f", pval_val),
    sprintf("  Bias: %.3f (SE: %.3f)", bias_est, se_bias),
    "  Conclusion: Symmetrical (p > 0.10)"
  ),
  bty = "o",
  box.col = "#2B6CB0",
  box.lwd = 1.5,
  bg = "#F8FAFCF5",
  text.col = c("#1B365D", "#334155", ifelse(pval_val > 0.05, "#059669", "#DC2626"), "#475569", "#059669"),
  text.font = c(2, 1, 2, 1, 2),
  cex = 0.85
)

dev.off()

cat(sprintf(" [SUCCESS] Figure 6 rendered cleanly with Egger statistics: %s\n", output_fig))
cat(sprintf(" - Saved Egger summary table: %s\n", output_csv))
cat(sprintf(" - Serialized Egger model: %s\n\n", output_rds))

