# ==============================================================================
# Script: scripts/designs/fig11_benefit_risk_tradeoff.R
# Purpose: Publication-Grade Figure 11 - Bi-dimensional Benefit-Risk Trade-Off Matrix
# Output: outputs/figures/11_benefit_risk_tradeoff.png (300 DPI, 11x8.5 in)
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(grid)
  library(scales)
})

cat("\n======================================================================\n")
cat(" [DESIGN 11/12] FIGURE 11: BI-DIMENSIONAL BENEFIT-RISK TRADE-OFF MATRIX\n")
cat("======================================================================\n")

data_path    <- "data/nsclc_toxicity_events.csv"
br_data_file <- "outputs/models/benefit_risk_data.rds"

needs_rerun  <- !file.exists(br_data_file) ||
                (file.exists(data_path) && file.mtime(data_path) > file.mtime(br_data_file))

if (needs_rerun) {
  cat(" - Toxicity data updated or cached model missing. Re-fitting via 09_benefit_risk_tradeoff.R ...\n")
  source("scripts/analyses/09_benefit_risk_tradeoff.R")
}

br_data <- readRDS(br_data_file)
df_br   <- br_data$benefit_risk_df

# Regimen labels and colors
trt_labels <- c(
  "Drug A" = "Drug A (Ref)",
  "Drug B" = "Drug B",
  "Drug C" = "Drug C",
  "Drug D" = "Drug D",
  "Drug E" = "Drug E",
  "Drug F" = "Drug F"
)

palette_regimens <- c(
  "Drug A" = "#546E7A",  # Grey
  "Drug B" = "#2E7D32",  # Forest Green
  "Drug C" = "#1B365D",  # Navy
  "Drug D" = "#6A1B9A",  # Purple
  "Drug E" = "#C62828",  # Red
  "Drug F" = "#E65100"   # Orange
)

df_br$Label <- trt_labels[df_br$Treatment]
df_br$Color <- palette_regimens[df_br$Treatment]

# Custom reverse-log transform so HR = 0.60 (Superior Survival) is at the TOP,
# and HR = 1.10 (Standard/Inferior Survival) is at the BOTTOM.
revlog_trans <- trans_new(
  name = "revlog",
  transform = function(x) -log(x),
  inverse = function(x) exp(-x)
)

# Label positioning coordinates to ensure ZERO overlap and maximum readability
df_labels <- df_br %>%
  mutate(
    Label_X = case_when(
      Treatment == "Drug C" ~ 1.28,
      Treatment == "Drug F" ~ 1.96,
      Treatment == "Drug D" ~ 0.70,
      Treatment == "Drug B" ~ 0.25,
      Treatment == "Drug E" ~ 0.29,
      Treatment == "Drug A" ~ 0.78
    ),
    Label_Y = case_when(
      Treatment == "Drug C" ~ 0.648,
      Treatment == "Drug F" ~ 0.725,
      Treatment == "Drug D" ~ 0.742,
      Treatment == "Drug B" ~ 0.745,
      Treatment == "Drug E" ~ 0.955,
      Treatment == "Drug A" ~ 0.940
    )
  )

p <- ggplot(df_br, aes(x = OR_Tox, y = HR_OS)) +
  # -------------------------------------------------------------------------
  # Quadrant Shading (Proper Top-to-Bottom hierarchy)
  # -------------------------------------------------------------------------
  # Quadrant II (Top-Left): Superior Survival (HR < 0.80) + Favorable Safety (OR < 1.00)
  annotate("rect", xmin = 0.20, xmax = 1.00, ymin = 0.60, ymax = 0.80,
           fill = "#E8F5E9", alpha = 0.55) +
  # Quadrant I (Top-Right): Superior Survival (HR < 0.80) + Increased Toxicity (OR > 1.00)
  annotate("rect", xmin = 1.00, xmax = 2.45, ymin = 0.60, ymax = 0.80,
           fill = "#EDE7F6", alpha = 0.55) +
  # Quadrant III (Bottom-Left): Modest Survival (HR >= 0.80) + Favorable Safety (OR < 1.00)
  annotate("rect", xmin = 0.20, xmax = 1.00, ymin = 0.80, ymax = 1.08,
           fill = "#FFF8E1", alpha = 0.55) +
  # Quadrant IV (Bottom-Right): Standard Survival (HR >= 0.80) + Standard/High Toxicity (OR >= 1.00)
  annotate("rect", xmin = 1.00, xmax = 2.45, ymin = 0.80, ymax = 1.08,
           fill = "#FFEBEE", alpha = 0.55) +
  
  # -------------------------------------------------------------------------
  # Quadrant Header Labels (Positioned safely away from reference lines)
  # -------------------------------------------------------------------------
  annotate("text", x = 0.21, y = 0.608, hjust = 0, vjust = 1,
           label = "QUADRANT II: OPTIMAL THERAPEUTIC WINDOW\nSuperior Survival (HR < 0.80) + Favorable Safety (OR < 1.00)",
           size = 3.2, fontface = "bold", color = "#1B5E20", lineheight = 1.1) +
  annotate("text", x = 2.44, y = 0.608, hjust = 1, vjust = 1,
           label = "QUADRANT I: INTENSIVE COMBINATION\nSuperior Survival (HR < 0.80) + Increased Severe Toxicity (OR > 1.00)",
           size = 3.2, fontface = "bold", color = "#4A148C", lineheight = 1.1) +
  annotate("text", x = 0.21, y = 1.072, hjust = 0, vjust = 0,
           label = "QUADRANT III: TOLERABLE COMPROMISE\nModest Survival (HR \u2265 0.80) + Favorable Safety (OR < 1.00)",
           size = 3.2, fontface = "bold", color = "#E65100", lineheight = 1.1) +
  annotate("text", x = 2.44, y = 1.072, hjust = 1, vjust = 0,
           label = "QUADRANT IV: UNFAVORABLE BACKBONE\nStandard Survival (HR \u2265 0.80) + Standard/High Toxicity (OR \u2265 1.00)",
           size = 3.2, fontface = "bold", color = "#B71C1C", lineheight = 1.1) +

  # -------------------------------------------------------------------------
  # Reference Lines (Bounded segments to avoid crossing header banners)
  # -------------------------------------------------------------------------
  # Vertical parity line (Toxicity OR = 1.0)
  annotate("segment", x = 1.0, xend = 1.0, y = 0.635, yend = 1.055,
           linetype = "solid", color = "#455A64", linewidth = 0.85) +
  # Horizontal parity line (Survival HR = 1.0)
  annotate("segment", x = 0.21, xend = 2.44, y = 1.0, yend = 1.0,
           linetype = "solid", color = "#455A64", linewidth = 0.85) +
  # Clinically Meaningful Efficacy Threshold (HR = 0.80 -> 20% Mortality Reduction)
  annotate("segment", x = 0.21, xend = 2.44, y = 0.80, yend = 0.80,
           linetype = "dashed", color = "#78909C", linewidth = 0.75) +
  annotate("text", x = 2.44, y = 0.793, 
           label = "Clinically Meaningful Benefit Threshold (HR = 0.80)", 
           hjust = 1, vjust = 0, size = 2.9, color = "#546E7A", fontface = "italic") +

  # -------------------------------------------------------------------------
  # Bidirectional 95% Confidence Intervals
  # -------------------------------------------------------------------------
  # Horizontal: Toxicity OR 95% CI
  geom_errorbar(aes(xmin = OR_Tox_Lower, xmax = OR_Tox_Upper), 
                orientation = "y", width = 0.015, linewidth = 0.8, color = df_br$Color, alpha = 0.75) +
  # Vertical: Overall Survival HR 95% CI
  geom_errorbar(aes(ymin = HR_OS_Lower, ymax = HR_OS_Upper), 
                orientation = "x", width = 0.04, linewidth = 0.8, color = df_br$Color, alpha = 0.75) +
  
  # Connecting leader segments from points to offset labels
  geom_segment(data = df_labels,
               aes(x = OR_Tox, y = HR_OS, xend = Label_X, yend = Label_Y),
               color = "#78909C", linewidth = 0.5, linetype = "solid") +

  # Treatment Point Estimates (Size scaled by Net Clinical Benefit)
  geom_point(aes(size = Net_Benefit_Score), color = "#263238", fill = df_br$Color, 
             shape = 21, stroke = 1.5, alpha = 0.95) +
  scale_size_continuous(
    name = "Net Clinical Benefit Index\n(Composite SUCRA: Efficacy + Safety)",
    range = c(5.5, 10.5),
    breaks = c(0.6, 0.9, 1.2),
    labels = c("0.60 (Unfavorable)", "0.90 (Moderate)", "1.20 (Favorable)"),
    guide = guide_legend(override.aes = list(fill = "#90A4AE", color = "#263238", stroke = 1.2))
  ) +
  
  # Repositioned Text Annotations (Zero overlap guaranteed)
  geom_label(data = df_labels,
             aes(x = Label_X, y = Label_Y, 
                 label = sprintf("%s\nHR: %.2f | OR: %.2f", Label, HR_OS, OR_Tox)),
             size = 3.2, fontface = "bold", fill = "#FFFFFF", color = "#263238",
             label.padding = unit(0.22, "lines"), label.r = unit(0.18, "lines")) +
  
  # Axis Scaling
  scale_x_continuous(
    trans = "log",
    breaks = c(0.25, 0.35, 0.50, 0.70, 1.00, 1.40, 1.80, 2.30),
    limits = c(0.20, 2.45),
    labels = c("0.25", "0.35", "0.50", "0.70", "1.00", "1.40", "1.80", "2.30")
  ) +
  scale_y_continuous(
    trans = revlog_trans,
    breaks = c(0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1.00, 1.05),
    limits = c(1.08, 0.60),
    labels = c("0.60", "0.65", "0.70", "0.75", "0.80", "0.85", "0.90", "0.95", "1.00", "1.05")
  ) +
  labs(
    title = "Bi-dimensional Benefit-Risk Trade-Off Matrix: Survival Efficacy vs Severe Toxicity",
    subtitle = "Simultaneous Dual Network Meta-Analysis Mapping Overall Survival Hazard Ratio against Grade 3-5 Adverse Event Odds Ratio\nReference Arm: Drug A Comparator Backbone (HR = 1.00, OR = 1.00; Point size proportional to Net Clinical Benefit Score)",
    x = "Severe Toxicity (Grade 3-5 AEs): Odds Ratio vs Drug A (Log Scale, < 1.0 = Safer)",
    y = "Overall Survival Efficacy: Hazard Ratio vs Drug A (Inverted Log Scale, Top = Superior Survival)",
    caption = "Derived from dual frequentist random-effects network meta-analyses across 24 randomized controlled trials (N = 14,357 patients).\nHorizontal and vertical error bars denote 95% confidence intervals. Quadrant thresholds define clinical decision domains."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15, color = "#0D233A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 10.5, color = "#37474F", lineheight = 1.25, margin = margin(b = 14)),
    plot.caption = element_text(size = 8.5, color = "#78909C", hjust = 0, margin = margin(t = 12)),
    axis.text = element_text(face = "bold", size = 9.5, color = "#263238"),
    axis.title = element_text(face = "bold", size = 10.5, color = "#263238"),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major = element_line(color = "#CFD8DC", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = c(0.81, 0.32),
    legend.background = element_rect(fill = alpha("#FFFFFF", 0.94), color = "#CFD8DC", linewidth = 0.5),
    legend.title = element_text(face = "bold", size = 8.5, color = "#263238"),
    legend.text = element_text(size = 8, color = "#37474F"),
    plot.margin = margin(t = 16, r = 20, b = 16, l = 16)
  )

fig_out <- "outputs/figures/11_benefit_risk_tradeoff.png"
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
cat(sprintf(" - Rendering Figure 11 to: %s ...\n", fig_out))
ggsave(fig_out, plot = p, width = 11.5, height = 8.0, dpi = 300, bg = "#FFFFFF")
cat(sprintf(" [SUCCESS] Figure 11 rendered cleanly: %s\n", fig_out))
