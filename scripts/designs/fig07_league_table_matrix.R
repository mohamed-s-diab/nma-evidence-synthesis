# ==============================================================================
# Design Script: scripts/designs/fig07_league_table_matrix.R
# Visual Target: Figure 7 - Dual-Model League Table Matrix Figure
# Output File:   outputs/figures/07_league_table_figure.png (300 DPI Publication Figure)
# Framework:     ggplot2 & netmeta (Uses Cached NMA Model & Hierarchy)
# ==============================================================================

suppressPackageStartupMessages({
  library(netmeta)
  library(ggplot2)
})

cat("\n======================================================================\n")
cat(" [DESIGN 07/12] FIGURE 07: PUBLICATION LEAGUE TABLE MATRIX FIGURE\n")
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
pscores_rand <- rk$ranking.random
trt_order <- names(sort(pscores_rand, decreasing = TRUE))
load_end_time <- Sys.time()
load_time_taken <- round(as.numeric(difftime(load_end_time, load_start_time, units="secs")), 3)
cat(sprintf(" - Loaded cached model & rankings in %.3f seconds.\n", load_time_taken))

# 2. Construct Matrix Coordinates & Styling
lg <- netleague(nma, digits = 2, seq = trt_order)
n_trts <- length(trt_order)
mat_rnd <- lg$random
pval_rnd <- nma$pval.random[trt_order, trt_order]

trt_meta <- lapply(seq_along(trt_order), function(idx) {
  t <- trt_order[idx]
  list(
    name = t,
    class = ifelse(t == "Drug A", "Reference Regimen", sprintf("Regimen %s", gsub("Drug ", "", t))),
    pscore = sprintf("%.1f%%", pscores_rand[t] * 100),
    rank = sprintf("Rank %d", idx)
  )
})
names(trt_meta) <- trt_order

cells_df <- data.frame()

for (i in 1:n_trts) {
  for (j in 1:n_trts) {
    row_trt <- trt_order[i]
    col_trt <- trt_order[j]
    cell_type <- if (i == j) "diagonal" else if (i > j) "lower" else "upper"
    
    tag_text <- ""
    hr_text <- ""
    ci_text <- ""
    bg_color <- "#FFFFFF"
    hr_color <- "#1E293B"
    ci_color <- "#64748B"
    tag_color <- "#94A3B8"
    hr_size <- 4.6
    hr_fontface <- "bold"
    
    val_str <- mat_rnd[i, j]
    
    if (cell_type == "diagonal") {
      meta_info <- trt_meta[[row_trt]]
      tag_text <- meta_info$class
      hr_text <- meta_info$name
      ci_text <- paste0(meta_info$rank, " • P-Score: ", meta_info$pscore)
      bg_color <- "#1E3A8A" # Deep Navy
      hr_color <- "#FFFFFF"
      ci_color <- "#FDE047" # Crisp Golden Yellow
      tag_color <- "#93C5FD" # Soft light blue
      hr_size <- 4.8
    } else if (cell_type == "lower") {
      # Lower triangle: Network Random Effects (Column vs Row)
      clean_v <- gsub(";", " –", val_str)
      parts <- strsplit(clean_v, " \\[")[[1]]
      hr_text <- paste0("HR ", parts[1])
      ci_text <- paste0("95% CI: ", gsub("\\]", "", parts[2]))
      
      p_val <- pval_rnd[i, j]
      is_sig <- (!is.na(p_val) && p_val < 0.05)
      
      if (is_sig) {
        bg_color <- "#DCFCE7" # Soft Mint Green
        hr_color <- "#14532D" # Deep Forest Green
        ci_color <- "#166534"
        tag_color <- "#15803D"
        tag_text <- "Network ★ p < 0.05"
      } else {
        bg_color <- "#F8FAFC" # Soft Neutral Slate
        hr_color <- "#334155"
        ci_color <- "#64748B"
        tag_color <- "#94A3B8"
        tag_text <- "Network (Random)"
      }
    } else if (cell_type == "upper") {
      # Upper triangle: Direct pairwise RCT evidence (Row vs Column)
      if (val_str == "." || is.na(val_str)) {
        tag_text <- "Direct Evidence"
        hr_text <- "—"
        ci_text <- "No direct head-to-head"
        bg_color <- "#F1F5F9"
        hr_color <- "#94A3B8"
        ci_color <- "#94A3B8"
        tag_color <- "#CBD5E1"
        hr_size <- 4.2
        hr_fontface <- "plain"
      } else {
        tag_text <- "Direct Evidence (RCT)"
        clean_v <- gsub(";", " –", val_str)
        parts <- strsplit(clean_v, " \\[")[[1]]
        hr_text <- paste0("HR ", parts[1])
        ci_text <- paste0("95% CI: ", gsub("\\]", "", parts[2]))
        bg_color <- "#EFF6FF" # Soft pastel blue
        hr_color <- "#1E40AF"
        ci_color <- "#2563EB"
        tag_color <- "#3B82F6"
      }
    }
    
    cells_df <- rbind(cells_df, data.frame(
      Row = i,
      Col = j,
      CellType = cell_type,
      Tag = tag_text,
      HR = hr_text,
      CI = ci_text,
      BG = bg_color,
      HRColor = hr_color,
      CIColor = ci_color,
      TagColor = tag_color,
      HRSize = hr_size,
      HRFontface = hr_fontface,
      stringsAsFactors = FALSE
    ))
  }
}

cells_df$X <- cells_df$Col
cells_df$Y <- n_trts - cells_df$Row + 1

axis_labels <- trt_order

p_league <- ggplot(cells_df) +
  geom_rect(aes(
    xmin = X - 0.47, xmax = X + 0.47,
    ymin = Y - 0.47, ymax = Y + 0.47,
    fill = BG
  ), color = "#CBD5E1", linewidth = 0.8) +
  scale_fill_identity() +
  geom_text(aes(x = X, y = Y + 0.28, label = Tag, color = TagColor),
            size = 2.6, fontface = "bold") +
  geom_text(aes(x = X, y = ifelse(CellType == "diagonal", Y + 0.02, Y + 0.03), 
                label = HR, color = HRColor,
                size = HRSize, fontface = HRFontface), lineheight = 0.95) +
  geom_text(aes(x = X, y = Y - 0.26, label = CI, color = CIColor),
            size = 2.85, fontface = "plain") +
  scale_size_identity() +
  scale_color_identity() +
  scale_x_continuous(
    breaks = 1:n_trts,
    labels = axis_labels,
    position = "top",
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  scale_y_continuous(
    breaks = 1:n_trts,
    labels = rev(axis_labels),
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  coord_fixed() +
  labs(
    title = "League Table of Pairwise Treatment Effects (Network vs Direct Evidence)",
    subtitle = "Treatments ordered by clinical hierarchy (P-scores) from top-left (best) to bottom-right (worst)",
    caption = paste0(
      "Reading Guide & Publication Conventions:\n",
      "• Lower Triangle (Green / Neutral): Network Meta-Analysis estimates from Random-Effects model (Column vs Row treatment).\n",
      "  Hazard Ratio (HR) < 1.0 indicates superiority of the higher-ranked Column treatment over the Row treatment.\n",
      "• Green Shading (★): Denotes statistically significant superior efficacy at the p < 0.05 threshold (95% CI excludes 1.0).\n",
      "• Upper Triangle (Light Blue): Direct pairwise meta-analysis estimates from Head-to-Head RCTs (dashes indicate purely indirect links).\n",
      "• Diagonal (Deep Navy): Treatment node names with their overall clinical hierarchy rank and P-score."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 16, color = "#0F172A", hjust = 0.5, margin = margin(b = 6)),
    plot.subtitle = element_text(size = 11.5, color = "#475569", hjust = 0.5, margin = margin(b = 16)),
    plot.caption = element_text(size = 9.2, color = "#334155", hjust = 0, lineheight = 1.38, margin = margin(t = 16)),
    axis.title = element_blank(),
    axis.text.x.top = element_text(size = 11, face = "bold", color = "#1E293B", margin = margin(b = 8)),
    axis.text.y = element_text(size = 11, face = "bold", color = "#1E293B", margin = margin(r = 8)),
    plot.margin = margin(t = 20, r = 25, b = 20, l = 25)
  )

# 3. Render Publication League Table Matrix Figure (300 DPI)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
output_fig <- "outputs/figures/07_league_table_figure.png"
cat(sprintf(" - Rendering Figure 7 to: %s ...\n", output_fig))

ggsave(output_fig, plot = p_league, width = 13.5, height = 13.5, dpi = 300)

cat(sprintf(" [SUCCESS] Figure 7 rendered cleanly: %s\n\n", output_fig))
