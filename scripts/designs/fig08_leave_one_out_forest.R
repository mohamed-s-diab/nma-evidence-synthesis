# ==============================================================================
# Design Script: scripts/designs/fig08_leave_one_out_forest.R
# Visual Target: Figure 8 - Leave-One-Out (LOO) Influence & Stability Forest Plot
# Output File:   outputs/figures/08_leave_one_out_forest.png (300 DPI Publication Exhibit)
# Focus:         Drug C vs Drug A Stability across 24 Trial Exclusions
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

cat("\n======================================================================\n")
cat(" [DESIGN 8/12] FIGURE 8: LEAVE-ONE-OUT SENSITIVITY FOREST PLOT\n")
cat("======================================================================\n")

# 1. Load Cached LOO Data (Auto-run analysis if missing)
loo_path <- "outputs/models/leave_one_out_data.rds"
data_path <- "data/nsclc_trial_contrasts.csv"

if (!file.exists(loo_path) || (file.exists(data_path) && file.mtime(data_path) > file.mtime(loo_path))) {
  cat(" - LOO cache missing or dataset modified. Running 06_leave_one_out_sensitivity.R ...\n")
  source("scripts/analyses/06_leave_one_out_sensitivity.R", local = new.env())
}

loo_bundle <- readRDS(loo_path)
df_loo <- loo_bundle$data

# Format labels and ordering
# Row 1 is baseline; rows 2:25 are exclusions
df_plot <- df_loo
df_plot$Label <- ifelse(df_plot$Iteration == 0, 
                        "★ Full Evidence Base (All 24 Trials)", 
                        gsub("Excluding ", "Omitting ", df_plot$Omitted_Study))

# Reverse order so baseline appears at the top of the plot
df_plot$Y_Rank <- nrow(df_plot):1
df_plot$Is_Baseline <- (df_plot$Iteration == 0)

baseline_hr  <- df_plot$Drug_C_HR[df_plot$Is_Baseline]
baseline_lci <- df_plot$Drug_C_LCI[df_plot$Is_Baseline]
baseline_uci <- df_plot$Drug_C_UCI[df_plot$Is_Baseline]

df_plot$HR_Label <- sprintf("%.2f [%.2f, %.2f]", 
                            df_plot$Drug_C_HR, df_plot$Drug_C_LCI, df_plot$Drug_C_UCI)
df_plot$Pscore_Label <- sprintf("P-Score: %.3f", df_plot$Pscore_Drug_C)

# 2. Construct Publication-Grade ggplot
p <- ggplot(df_plot, aes(y = factor(Y_Rank, levels = 1:nrow(df_plot), labels = df_plot$Label[order(df_plot$Y_Rank)]))) +
  # Baseline reference band
  annotate("rect", xmin = baseline_lci, xmax = baseline_uci, ymin = -Inf, ymax = Inf,
           fill = "#3B82F6", alpha = 0.08) +
  # Baseline point estimate dashed line
  geom_vline(xintercept = baseline_hr, color = "#1E40AF", linetype = "dashed", size = 0.7, alpha = 0.8) +
  # Line of no effect
  geom_vline(xintercept = 1.0, color = "#94A3B8", linetype = "solid", size = 0.6) +
  # Error bars
  geom_errorbarh(aes(xmin = Drug_C_LCI, xmax = Drug_C_UCI, color = Is_Baseline),
                 height = 0.25, size = 0.8) +
  # Points
  geom_point(aes(x = Drug_C_HR, color = Is_Baseline, shape = Is_Baseline, size = Is_Baseline)) +
  # Text annotations on right margin
  geom_text(aes(x = 1.05, label = HR_Label, fontface = ifelse(Is_Baseline, "bold", "plain")),
            hjust = 0, size = 3.3, family = "sans", color = "#1E293B") +
  geom_text(aes(x = 1.28, label = Pscore_Label, fontface = ifelse(Is_Baseline, "bold", "italic")),
            hjust = 0, size = 3.0, family = "sans", color = "#475569") +
  # Scales & Colors
  scale_color_manual(values = c("TRUE" = "#B91C1C", "FALSE" = "#0F766E"), guide = "none") +
  scale_shape_manual(values = c("TRUE" = 18, "FALSE" = 16), guide = "none") +
  scale_size_manual(values = c("TRUE" = 4.5, "FALSE" = 2.8), guide = "none") +
  scale_x_continuous(
    trans = "log",
    breaks = c(0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 1.00, 1.20),
    limits = c(0.38, 1.45),
    labels = c("0.40", "0.50", "0.60", "0.70", "0.80", "0.90", "1.00", "1.20")
  ) +
  labs(
    title = "Leave-One-Out (LOO) Influence Cross-Validation: Drug C vs Drug A",
    subtitle = sprintf("Overall Survival Hazard Ratio across 24 systematic trial omissions | Baseline Pooled HR = %.2f [%.2f, %.2f] (Rank 1 in 100%% of Iterations)",
                       baseline_hr, baseline_lci, baseline_uci),
    x = "Hazard Ratio (95% CI) — Log Scale (HR < 1.0 Favors Drug C)",
    y = "Iterative Evidence Subset (Single Trial Omitted)"
  ) +
  theme_minimal(base_size = 11, base_family = "sans") +
  theme(
    plot.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.background = element_rect(fill = "#FAFAFA", color = "#E2E8F0"),
    panel.grid.major.y = element_line(color = "#F1F5F9", size = 0.4),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E2E8F0", size = 0.5),
    axis.text.y = element_text(size = 9, color = "#0F172A", face = ifelse(rev(df_plot$Is_Baseline), "bold", "plain")),
    axis.text.x = element_text(size = 9, color = "#334155"),
    axis.title.x = element_text(size = 10, face = "bold", color = "#1E293B", margin = margin(t = 10)),
    axis.title.y = element_text(size = 10, face = "bold", color = "#1E293B", margin = margin(r = 10)),
    plot.title = element_text(size = 13, face = "bold", color = "#0F172A", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.5, color = "#475569", margin = margin(b = 15)),
    plot.margin = margin(t = 16, r = 16, b = 16, l = 16)
  )

# 3. Export High-Resolution 300 DPI Figure
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/08_leave_one_out_forest.png"

cat(sprintf(" - Rendering Figure 8 to: %s ...\n", output_fig))
ggsave(output_fig, plot = p, width = 12, height = 9, dpi = 300)

cat(sprintf(" [SUCCESS] Figure 8 rendered cleanly: %s\n", output_fig))
cat("\n")
