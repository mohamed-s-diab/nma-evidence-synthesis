# ==============================================================================
# Design Script: scripts/designs/fig03_pscore_ranking.R
# Visual Target: Figure 3 - Treatment Ranking Hierarchy (P-Scores / SUCRA)
# Output File:   outputs/figures/03_pscore_ranking.png (300 DPI Publication Figure)
# Framework:     ggplot2 & netmeta (Uses Cached Hierarchy)
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(scales)
})

cat("\n======================================================================\n")
cat(" [DESIGN 03/12] FIGURE 03: TREATMENT RANKING (P-SCORE HIERARCHY)\n")
cat("======================================================================\n")

# 1. Load Cached Rankings Object (Auto-fit if missing or data changed)
ranking_path <- "outputs/models/nma_rankings.rds"
data_path    <- "data/nsclc_trial_contrasts.csv"

needs_refit <- !file.exists(ranking_path) ||
               (file.exists(data_path) && file.mtime(data_path) > file.mtime(ranking_path))

if (needs_refit) {
  cat(" - Dataset updated or cached rankings missing. Re-fitting model via 01_fit_nma_model.R ...\n")
  refit_env <- new.env(parent = globalenv())
  refit_env$force_refit <- TRUE
  source("scripts/analyses/01_fit_nma_model.R", local = refit_env)
}

load_start_time <- Sys.time()
rk <- readRDS(ranking_path)
pscores_rand <- rk$ranking.random
trt_order <- names(sort(pscores_rand, decreasing = TRUE))
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached rankings in %.3f seconds.\n", load_time_taken))

trt_labels_map <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

df_rankings <- data.frame(
  Treatment = trt_labels_map[trt_order],
  Rank = 1:length(trt_order),
  Pscore_Random = round(pscores_rand[trt_order], 4),
  stringsAsFactors = FALSE
)

# 2. Render Publication Ranking Hierarchy Bar Chart (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/03_pscore_ranking.png"
cat(sprintf(" - Rendering Figure 3 to: %s ...\n", output_fig))

df_plot_rank <- df_rankings
df_plot_rank$Treatment <- factor(df_plot_rank$Treatment, levels = rev(df_rankings$Treatment))

colors_by_trt <- c(
  "Drug A" = "#718096",
  "Drug B" = "#3182CE",
  "Drug C" = "#2B6CB0",
  "Drug D" = "#805AD5",
  "Drug E" = "#D69E2E",
  "Drug F" = "#DD6B20"
)

p_rank <- ggplot(df_plot_rank, aes(x = Pscore_Random, y = Treatment, fill = Treatment)) +
  geom_col(width = 0.65, alpha = 0.9, color = "#2D3748", linewidth = 0.4) +
  geom_text(aes(label = sprintf("Rank #%d | P-score: %.1f%%", Rank, Pscore_Random * 100)),
            hjust = -0.08, size = 4.2, fontface = "bold", color = "#1A202C") +
  scale_fill_manual(values = colors_by_trt) +
  scale_x_continuous(limits = c(0, 1.25), breaks = seq(0, 1, 0.2), 
                     labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Treatment Ranking Hierarchy: Surface Under Cumulative Ranking (P-Scores)",
    subtitle = "Overall Survival Evidence Synthesis (Frequentist random-effects model)",
    x = "P-Score (Certainty of Superiority over Competing Regimens)",
    y = NULL,
    caption = "P-score ranges from 0 (certain worst) to 1 (certain best).\nComputed using netrank(..., small.values = 'good')."
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "#E2E8F0", linetype = "dashed"),
    plot.title = element_text(face = "bold", size = 16, color = "#1A365D"),
    plot.subtitle = element_text(color = "#4A5568", size = 12, margin = margin(b = 15)),
    axis.text.y = element_text(face = "bold", size = 12, color = "#2D3748"),
    axis.title.x = element_text(face = "bold", size = 12, margin = margin(t = 10))
  )

ggsave(output_fig, plot = p_rank, width = 10, height = 6.5, dpi = 300)

cat(sprintf(" [SUCCESS] Figure 3 rendered cleanly: %s\n\n", output_fig))
