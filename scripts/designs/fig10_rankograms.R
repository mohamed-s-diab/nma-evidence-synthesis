# ==============================================================================
# Script: scripts/designs/fig10_rankograms.R
# Purpose: Publication-Grade Figure 10 - Probabilistic Treatment Hierarchy & Rankograms
# Output: outputs/figures/10_rankograms.png (300 DPI, 12x8.5 in)
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(grid)
})

cat("\n======================================================================\n")
cat(" [DESIGN 10/12] FIGURE 10: PROBABILISTIC RANKOGRAMS & CUMULATIVE CURVES\n")
cat("======================================================================\n")

rank_data_file <- "outputs/models/rank_probabilities_data.rds"
if (!file.exists(rank_data_file)) {
  cat(" - Rank data cache missing. Running 08_rank_probabilities.R ...\n")
  source("scripts/analyses/08_rank_probabilities.R")
}

rank_data  <- readRDS(rank_data_file)
df_summary <- rank_data$summary_table
rank_mat   <- rank_data$rank_prob_mat
cum_mat    <- rank_data$cum_prob_mat

# Regimen clinical labels and colors
trt_labels <- c(
  "Drug A" = "Drug A",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

palette_regimens <- c(
  "Drug A" = "#546E7A",  # Slate Grey
  "Drug B" = "#00838F",  # Teal Cyan
  "Drug C" = "#1B365D",  # Deep Navy
  "Drug D" = "#6A1B9A",  # Royal Purple
  "Drug E" = "#C62828",  # Crimson
  "Drug F" = "#E65100"   # Amber/Orange
)

# Convert rank matrix to long format for ggplot2
df_long <- as.data.frame(rank_mat)
df_long$Treatment <- rownames(rank_mat)

df_plot <- df_long %>%
  pivot_longer(cols = starts_with("Rank_"), names_to = "Rank_Str", values_to = "Probability") %>%
  mutate(
    Rank = as.numeric(gsub("Rank_", "", Rank_Str)),
    Clinical_Name = trt_labels[Treatment]
  )

# Add cumulative probabilities
df_cum_long <- as.data.frame(cum_mat)
df_cum_long$Treatment <- rownames(cum_mat)
df_cum_plot <- df_cum_long %>%
  pivot_longer(cols = starts_with("Rank_"), names_to = "Rank_Str", values_to = "Cum_Probability") %>%
  mutate(
    Rank = as.numeric(gsub("Rank_", "", Rank_Str)),
    Clinical_Name = trt_labels[Treatment]
  )

df_plot <- left_join(df_plot, df_cum_plot, by = c("Treatment", "Rank", "Clinical_Name", "Rank_Str"))

# Order facets by SUCRA score descending
ordered_trts <- df_summary$Treatment
df_plot$Treatment <- factor(df_plot$Treatment, levels = ordered_trts)

# Create facet labels with SUCRA and Mean Rank
facet_labels <- setNames(
  sprintf("%s\nSUCRA: %.1f%%  |  Mean Rank: %.2f  |  P(Best): %.1f%%",
          trt_labels[df_summary$Treatment],
          df_summary$SUCRA * 100,
          df_summary$Mean_Rank,
          df_summary$Rank_1 * 100),
  df_summary$Treatment
)

# Separate labels into internal (inside tall bars) and external (above short bars)
df_plot <- df_plot %>%
  mutate(
    Label_Text = ifelse(Probability >= 0.02, sprintf("%.1f%%", Probability * 100), ""),
    Is_Tall    = Probability >= 0.08,
    # For tall bars, place label in center of bar (safe from the cumulative curve above)
    Y_Pos      = ifelse(Is_Tall, Probability * 0.45, Probability + 0.04),
    Text_Color = ifelse(Is_Tall, "#FFFFFF", "#263238")
  )

p <- ggplot(df_plot, aes(x = Rank)) +
  # Background subtle shading for ideal ranks (Rank 1-2)
  annotate("rect", xmin = 0.5, xmax = 2.5, ymin = 0, ymax = 1.05, 
           fill = "#F0F4F8", alpha = 0.45) +
  # Bar chart for discrete rank probabilities
  geom_col(aes(y = Probability, fill = Treatment), width = 0.68, alpha = 0.88, color = "#263238", linewidth = 0.3) +
  # Cumulative ranking line and points
  geom_line(aes(y = Cum_Probability), color = "#37474F", linewidth = 1.1, linetype = "solid") +
  geom_point(aes(y = Cum_Probability), color = "#B71C1C", fill = "#FFFFFF", shape = 21, size = 2.8, stroke = 1.5) +
  # Text labels placed intelligently inside tall bars or just above short bars
  geom_text(aes(y = Y_Pos, label = Label_Text, color = Text_Color),
            size = 3.2, fontface = "bold") +
  scale_color_identity() +
  # Faceting
  facet_wrap(~ Treatment, ncol = 3, labeller = as_labeller(facet_labels)) +
  scale_fill_manual(values = palette_regimens, guide = "none") +
  scale_x_continuous(breaks = 1:6, labels = paste0("Rank ", 1:6)) +
  scale_y_continuous(
    limits = c(0, 1.10),
    breaks = seq(0, 1, 0.25),
    labels = c("0%", "25%", "50%", "75%", "100%"),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Probabilistic Treatment Hierarchy & Full Rankograms (10,000 Monte Carlo Draws)",
    subtitle = "Discrete Probability of Occupying Each Rank (Filled Bars) with Cumulative Ranking Curves (Black Line & Red Circles)\nRank 1 indicates most favorable overall survival; SUCRA measures overall hierarchy percentage across all competing regimens.",
    x = "Treatment Hierarchy Rank (Rank 1 = Most Effective, Rank 6 = Least Effective)",
    y = "Probability / Cumulative Probability",
    caption = "Derived from 10,000 multivariate normal draws parameterized by network point estimates and random-effects covariance (Salanti et al., 2011).\nFilled Bars: P(Rank = r). Line & Points: Cumulative SUCRA Curve. SUCRA: Surface Under the Cumulative RAnking curve. P(Best) = Probability of occupying Rank 1."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15, color = "#0D233A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 10.5, color = "#37474F", lineheight = 1.25, margin = margin(b = 14)),
    plot.caption = element_text(size = 8.5, color = "#78909C", hjust = 0, margin = margin(t = 12)),
    strip.text = element_text(face = "bold", size = 10, color = "#FFFFFF", lineheight = 1.15),
    strip.background = element_rect(fill = "#1B365D", color = NA),
    axis.text.x = element_text(face = "bold", size = 9, color = "#263238"),
    axis.text.y = element_text(size = 9, color = "#37474F"),
    axis.title = element_text(face = "bold", size = 10.5, color = "#263238"),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major = element_line(color = "#ECEFF1", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    panel.spacing = unit(1.2, "lines"),
    plot.margin = margin(t = 16, r = 18, b = 16, l = 16)
  )

fig_out <- "outputs/figures/10_rankograms.png"
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
cat(sprintf(" - Rendering Figure 10 to: %s ...\n", fig_out))
ggsave(fig_out, plot = p, width = 12, height = 8.5, dpi = 300, bg = "#FFFFFF")
cat(sprintf(" [SUCCESS] Figure 10 rendered cleanly: %s\n", fig_out))
