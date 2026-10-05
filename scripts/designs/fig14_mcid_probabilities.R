# ==============================================================================
# Design Script: scripts/designs/fig14_mcid_probabilities.R
# Visual Target: Figure 14 - MCID Clinical Superiority Probability Framework (HR <= 0.80)
# Output File:   outputs/figures/14_mcid_probabilities.png (300 DPI Publication Exhibit)
# Focus:         Dual Exhibit: (A) Superiority vs Drug A; (B) Pairwise MCID Matrix
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(patchwork)
  library(grid)
})

cat("\n======================================================================\n")
cat(" [DESIGN 14/14] FIGURE 14: MCID CLINICAL SUPERIORITY PROBABILITY ENGINE (REFINED)\n")
cat("======================================================================\n")

# 1. Load Cached MCID Analysis Data
mcid_data_path <- "outputs/models/mcid_analysis_data.rds"
data_path      <- "data/trial_contrasts.csv"

if (!file.exists(mcid_data_path) || (file.exists(data_path) && file.mtime(data_path) > file.mtime(mcid_data_path))) {
  cat(" - MCID data cache missing or modified. Running 12_mcid_analysis.R ...\n")
  source("scripts/analyses/12_mcid_analysis.R", local = new.env())
}

mcid_bundle <- readRDS(mcid_data_path)
df_summary  <- mcid_bundle$summary_table
mcid_mat    <- mcid_bundle$mcid_pairwise_mat
trts_all    <- mcid_bundle$trts

trt_labels_clean <- c(
  "Drug A" = "Drug A Anchor",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

trt_short_labels <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

palette_regimens <- c(
  "Drug A" = "#64748B",
  "Drug B" = "#00838F",
  "Drug C" = "#1B365D",
  "Drug D" = "#6A1B9A",
  "Drug E" = "#C62828",
  "Drug F" = "#E65100"
)

# ------------------------------------------------------------------------------
# PANEL A: MCID vs Standard Drug A Anchor
# ------------------------------------------------------------------------------
df_bar <- df_summary %>%
  filter(Treatment != "Drug A") %>%
  mutate(
    Clean_Label = trt_labels_clean[Treatment],
    Treatment_Factor = factor(Treatment, levels = rev(c("Drug C", "Drug F", "Drug D", "Drug B", "Drug E"))),
    MCID_Pct = P_MCID_vs_Drug_A * 100,
    Sup_Pct  = P_Superior_vs_Drug_A * 100,
    Label_Text = sprintf("P(MCID): %.1f%%  |  P(HR < 1.0): %.1f%%", MCID_Pct, Sup_Pct)
  )

p1 <- ggplot(df_bar, aes(y = Treatment_Factor, x = MCID_Pct, fill = Treatment)) +
  # Background reference bar up to 100%
  geom_col(aes(x = 100), fill = "#F1F5F9", width = 0.58) +
  # Active MCID bar
  geom_col(width = 0.58, show.legend = FALSE) +
  # Reference line at 100% boundary
  geom_vline(xintercept = 100, linetype = "dashed", color = "#CBD5E1", linewidth = 0.6) +
  # High-contrast label positioned strictly outside the bar with no clipping
  geom_text(
    aes(label = Label_Text, x = MCID_Pct + 1.8),
    hjust = 0, size = 3.5, fontface = "bold", color = "#1E293B", family = "sans"
  ) +
  scale_fill_manual(values = palette_regimens) +
  scale_y_discrete(labels = trt_labels_clean) +
  scale_x_continuous(
    limits = c(0, 152),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "PANEL A: Probability of Clinically Meaningful Superiority vs. Drug A Anchor",
    subtitle = "MCID Threshold: HR <= 0.80 (>= 20% Relative Mortality Reduction) Across 10,000 Multivariate Monte Carlo Simulations",
    x = "Probability of Achieving Clinically Meaningful Benefit (%)",
    y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 11.5, color = "#0F172A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.2, color = "#475569", margin = margin(b = 10)),
    axis.text.y = element_text(face = "bold", size = 10, color = "#1E293B"),
    axis.text.x = element_text(size = 9, color = "#475569"),
    axis.title.x = element_text(face = "bold", size = 9.5, color = "#1E293B", margin = margin(t = 6)),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E2E8F0", linewidth = 0.5),
    plot.margin = margin(t = 10, r = 24, b = 14, l = 10)
  )

# ------------------------------------------------------------------------------
# PANEL B: Complete 6x6 Pairwise MCID Heatmap Matrix
# ------------------------------------------------------------------------------
df_heatmap <- as.data.frame(as.table(mcid_mat))
colnames(df_heatmap) <- c("Trt_Row", "Trt_Col", "Prob")

order_matrix <- c("Drug C", "Drug F", "Drug D", "Drug B", "Drug E", "Drug A")

df_heatmap$Trt_Row <- factor(df_heatmap$Trt_Row, levels = rev(order_matrix))
df_heatmap$Trt_Col <- factor(df_heatmap$Trt_Col, levels = order_matrix)
df_heatmap$Is_Diagonal <- (df_heatmap$Trt_Row == df_heatmap$Trt_Col)
df_heatmap$Prob_Pct <- df_heatmap$Prob * 100

df_heatmap$Cell_Label <- ifelse(
  df_heatmap$Is_Diagonal, "—",
  sprintf("%.1f%%", df_heatmap$Prob_Pct)
)

# Text color rule: > 35% is white, <= 35% is dark navy #0F172A
p2 <- ggplot(df_heatmap, aes(x = Trt_Col, y = Trt_Row, fill = Prob_Pct)) +
  geom_tile(color = "white", linewidth = 1.2) +
  geom_text(
    aes(label = Cell_Label, color = ifelse(Prob_Pct > 35, "white", "#0F172A")),
    size = 3.3, fontface = ifelse(df_heatmap$Is_Diagonal, "plain", "bold"), family = "sans"
  ) +
  scale_fill_gradient2(
    low = "#F8FAFC", mid = "#60A5FA", high = "#1E3A8A",
    midpoint = 45, limits = c(0, 100),
    name = "P(HR <= 0.80):",
    labels = function(x) paste0(x, "%")
  ) +
  scale_color_identity() +
  scale_x_discrete(labels = trt_short_labels, position = "top") +
  scale_y_discrete(labels = trt_short_labels) +
  labs(
    title = "PANEL B: Pairwise Head-to-Head MCID Probability Matrix",
    subtitle = "Cell (Row vs. Column) = Probability that Active Row Regimen Achieves HR <= 0.80 over Column Regimen",
    x = "Comparator Regimen",
    y = "Active Treatment Regimen"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 11.5, color = "#0F172A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.2, color = "#475569", margin = margin(b = 12)),
    axis.text = element_text(face = "bold", size = 9.5, color = "#1E293B"),
    axis.title.x.top = element_text(face = "bold", size = 10, color = "#0F172A", margin = margin(b = 10)),
    axis.title.y = element_text(face = "bold", size = 10, color = "#0F172A", margin = margin(r = 10)),
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 9, color = "#0F172A"),
    legend.text = element_text(size = 8.5, color = "#334155"),
    panel.grid = element_blank(),
    plot.margin = margin(t = 12, r = 10, b = 10, l = 10)
  )

# Combine Panels with Patchwork
fig14_combined <- p1 / p2 +
  plot_layout(heights = c(1, 1.28)) +
  plot_annotation(
    title = "Figure 14: Minimal Clinically Important Difference (MCID) Probabilistic Decision Framework",
    subtitle = "10,000 Monte Carlo Multivariate Normal Simulations Quantifying Clinically Significant Survival Advantages (HR <= 0.80)",
    caption = "MCID defined according to ASCO/ESMO clinical benefit framework (>= 20% relative reduction in overall mortality risk, HR <= 0.80).\nModel parameterized by random-effects network covariance matrix (Sigma) centered at NMA relative effect estimates.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 14, color = "#0F172A", margin = margin(b = 4)),
      plot.subtitle = element_text(size = 10.5, color = "#334155", margin = margin(b = 10)),
      plot.caption = element_text(size = 8.5, color = "#64748B", hjust = 0, lineheight = 1.25, margin = margin(t = 10))
    )
  )

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/14_mcid_probabilities.png"
png(output_fig, width = 3400, height = 2600, res = 300)
print(fig14_combined)
dev.off()

cat(sprintf(" [SUCCESS] Figure 14 rendered cleanly: %s\n\n", output_fig))
