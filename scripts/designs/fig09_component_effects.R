# ==============================================================================
# Script: scripts/designs/fig09_component_effects.R
# Purpose: Publication-Grade Figure 09 - Component Network Meta-Analysis (CNMA)
# Output: outputs/figures/09_component_effects.png (300 DPI, 11.5x8.0 in)
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(grid)
})

cat("\n======================================================================\n")
cat(" [DESIGN 9/12] FIGURE 9: COMPONENT NETWORK META-ANALYSIS (CNMA) FOREST\n")
cat("======================================================================\n")

cnma_data_file <- "outputs/models/component_nma_data.rds"
if (!file.exists(cnma_data_file)) {
  cat(" - CNMA cache missing. Running 07_component_nma.R ...\n")
  source("scripts/analyses/07_component_nma.R")
}

cnma <- readRDS(cnma_data_file)
df_comp <- cnma$components_df
df_comb <- cnma$combinations_df

# Component clinical display labels
comp_labels <- c(
  "Component B" = "Component B",
  "Component D" = "Component D",
  "Component C" = "Component C"
)

comb_labels <- c(
  "Component A + Component B" = "Component A + Component B (Additive CNMA)",
  "Component A + Component D" = "Component A + Component D (Additive CNMA)",
  "Component B + Component C" = "Component B + Component C (Additive CNMA)",
  "Component B"               = "Component B Monotherapy (Additive CNMA)",
  "Component D"               = "Component D Monotherapy (Additive CNMA)"
)

df_comp$Display_Name <- comp_labels[df_comp$Item]
df_comb$Display_Name <- comb_labels[df_comb$Item]

# Clean, prominent horizontal category titles
df_comp$Category <- "PANEL A: Marginal Incremental Effects of Individual Components (Added to Component A Backbone)"
df_comb$Category <- "PANEL B: Predicted Regimen Efficacy under Additive Model (vs Component A Backbone)"

# Harmonized color palette
df_comp$Color <- c("#1B365D", "#2E7D32", "#C62828") # Component C, B, D
df_comb$Color <- c("#00838F", "#E65100", "#6A1B9A", "#2E7D32", "#C62828")

df_plot <- rbind(
  df_comp %>% select(Category, Display_Name, iHR, CI_Lower, CI_Upper, HR_String, P_Value_String, Color),
  df_comb %>% select(Category, Display_Name, iHR, CI_Lower, CI_Upper, HR_String, P_Value_String, Color)
)

# Order items logically within each category
df_plot$Display_Name <- factor(df_plot$Display_Name, levels = rev(c(
  "Component B",
  "Component D",
  "Component C",
  "Component A + Component B (Additive CNMA)",
  "Component A + Component D (Additive CNMA)",
  "Component B + Component C (Additive CNMA)",
  "Component B Monotherapy (Additive CNMA)",
  "Component D Monotherapy (Additive CNMA)"
)))

df_plot$Category <- factor(df_plot$Category, levels = c(
  "PANEL A: Marginal Incremental Effects of Individual Components (Added to Component A Backbone)",
  "PANEL B: Predicted Regimen Efficacy under Additive Model (vs Component A Backbone)"
))

p <- ggplot(df_plot, aes(x = iHR, y = Display_Name)) +
  # Null effect reference line
  geom_vline(xintercept = 1.0, linetype = "dashed", color = "#78909C", linewidth = 0.8) +
  # Horizontal Facet Wrap for full-width banner headers (NO cutting off text!)
  facet_wrap(~ Category, ncol = 1, scales = "free_y") +
  # Error bars
  geom_errorbar(aes(xmin = CI_Lower, xmax = CI_Upper), 
                width = 0.22, orientation = "y", linewidth = 0.9, color = df_plot$Color) +
  # Diamond point estimates
  geom_point(shape = 18, size = 5.2, color = df_plot$Color) +
  # Text labels for numerical estimates (cleanly aligned on right)
  geom_text(aes(x = 1.32, label = sprintf("%s  |  p %s", HR_String, P_Value_String)),
            hjust = 0, size = 3.6, fontface = "bold", color = "#263238") +
  scale_x_continuous(
    trans = "log",
    breaks = c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3),
    limits = c(0.55, 2.15),
    labels = c("0.50", "0.60", "0.70", "0.80", "0.90", "1.00", "1.10", "1.20", "1.30")
  ) +
  labs(
    title = "Component Network Meta-Analysis (CNMA): Deconstruction of Regimen Synergy",
    subtitle = sprintf("Marginal Incremental Hazard Ratios (iHR) & Additive Combinations vs Component A Anchor Backbone\nSynergy Test vs Standard NMA: Q_diff = %.2f (df = %d, p = %.4f -> Significant Multi-Agent Synergistic Interaction Detected)",
                       cnma$Q_diff, cnma$df_Q_diff, cnma$pval_Q_diff),
    x = "Incremental Hazard Ratio (iHR) & 95% Confidence Interval (Log Scale)",
    y = NULL,
    caption = "Frequentist Additive CNMA Model (Rücker et al., 2020) fitted using netmeta::netcomb(). Anchor Reference = Component A.\niHR < 1.0 indicates improved Overall Survival when adding component/combination; iHR > 1.0 indicates diminished survival."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#0D233A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 10, color = "#37474F", lineheight = 1.25, margin = margin(b = 14)),
    plot.caption = element_text(size = 8.5, color = "#78909C", hjust = 0, margin = margin(t = 12)),
    axis.text.y = element_text(face = "bold", size = 10.5, color = "#263238"),
    axis.text.x = element_text(size = 9.5, color = "#37474F"),
    axis.title.x = element_text(face = "bold", size = 10.5, color = "#263238", margin = margin(t = 10)),
    # Full-width horizontal strip headers
    strip.text = element_text(face = "bold", size = 10.5, color = "#FFFFFF", hjust = 0, margin = margin(t = 6, b = 6, l = 8)),
    strip.background = element_rect(fill = "#1B365D", color = NA),
    panel.grid.major.x = element_line(color = "#ECEFF1", linewidth = 0.5),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#F5F5F5", linewidth = 0.5),
    panel.spacing = unit(1.2, "lines"),
    plot.margin = margin(t = 16, r = 22, b = 16, l = 16)
  )

# Add single unified Direction of Benefit annotation at bottom
p <- p +
  annotate("text", x = 0.75, y = 0.52, label = "◄ Favors Component Addition", 
           size = 3.2, fontface = "bold", color = "#2E7D32") +
  annotate("text", x = 1.15, y = 0.52, label = "Favors Backbone Only ►", 
           size = 3.2, fontface = "bold", color = "#C62828")

fig_out <- "outputs/figures/09_component_effects.png"
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
cat(sprintf(" - Rendering Figure 9 to: %s ...\n", fig_out))
ggsave(fig_out, plot = p, width = 11.5, height = 8.0, dpi = 300, bg = "#FFFFFF")
cat(sprintf(" [SUCCESS] Figure 9 rendered cleanly: %s\n", fig_out))
