# ==============================================================================
# Script: scripts/analyses/05_league_table_html.R
# Purpose: Export Publication-Formatted Interactive HTML League Table
# Input:   outputs/tables/league_table_random_common.csv
# Output:  outputs/tables/league_table_formatted.html
# ==============================================================================

cat("\n======================================================================\n")
cat(" [ANALYSIS 05/12] FORMATTED HTML LEAGUE TABLE GENERATOR\n")
cat("======================================================================\n")

# 1. Load or Generate Raw League Matrix Data
csv_path  <- "outputs/tables/league_table_random_common.csv"
data_path <- "data/trial_contrasts.csv"

needs_regenerate <- !file.exists(csv_path) ||
                    (file.exists(data_path) && file.mtime(data_path) > file.mtime(csv_path))

if (needs_regenerate) {
  cat(" - Raw league matrix CSV missing or data updated. Running scripts/analyses/03_league_table.R ...\n")
  source("scripts/analyses/03_league_table.R", local = new.env())
}

mat <- read.csv(csv_path, row.names = 1, check.names = FALSE, stringsAsFactors = FALSE)
trt_order <- colnames(mat)
cat(sprintf(" - Loaded league matrix: %d treatments (%s)\n", ncol(mat), paste(trt_order, collapse = ", ")))

# 2. Build Publication-Grade HTML & CSS Table
output_html <- "outputs/tables/league_table_formatted.html"
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

html_table <- paste0(
  "<div style='font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; margin: 24px 0;'>\n",
  "<h3 style='color: #1A365D; text-align: center; font-size: 1.25em; margin-bottom: 6px;'>Table: League Table of Pairwise Treatment Comparisons (Hazard Ratios [95% CI])</h3>\n",
  "<p style='text-align: center; color: #4A5568; font-size: 0.9em; margin-bottom: 16px;'>",
  "Treatments ordered by clinical hierarchy (P-scores) from top-left (best) to bottom-right (worst).<br>",
  "<b>Lower Triangle:</b> Random-Effects Model | <b>Upper Triangle:</b> Common-Effects Model | <b>Bold:</b> Statistically Significant",
  "</p>\n",
  "<table style='border-collapse: collapse; margin: 0 auto; width: 95%; box-shadow: 0 4px 8px rgba(0,0,0,0.08); border-radius: 8px; overflow: hidden; font-size: 0.95em;'>\n",
  "  <thead>\n    <tr style='background-color: #2B6CB0; color: white; text-align: center; font-weight: bold;'>\n",
  "      <th style='padding: 12px 14px; border: 1px solid #CBD5E0;'>Treatment</th>\n",
  paste0(sprintf("      <th style='padding: 12px 14px; border: 1px solid #CBD5E0;'>%s</th>\n", trt_order), collapse = ""),
  "    </tr>\n  </thead>\n  <tbody>\n"
)

for (i in 1:nrow(mat)) {
  row_html <- sprintf("    <tr style='background-color: %s; text-align: center;'>\n", ifelse(i %% 2 == 0, "#F7FAFC", "#FFFFFF"))
  row_html <- paste0(row_html, sprintf("      <td style='padding: 10px 12px; font-weight: bold; background-color: #EDF2F7; border: 1px solid #CBD5E0; color: #1A202C;'>%s</td>\n", rownames(mat)[i]))
  
  for (j in 1:ncol(mat)) {
    val <- mat[i, j]
    is_diag <- (i == j)
    cell_style <- if (is_diag) {
      "padding: 10px 12px; font-weight: bold; background-color: #BEE3F8; color: #2B6CB0; border: 1px solid #CBD5E0;"
    } else {
      "padding: 10px 12px; border: 1px solid #CBD5E0; color: #2D3748;"
    }
    row_html <- paste0(row_html, sprintf("      <td style='%s'>%s</td>\n", cell_style, val))
  }
  row_html <- paste0(row_html, "    </tr>\n")
  html_table <- paste0(html_table, row_html)
}

html_table <- paste0(
  html_table,
  "  </tbody>\n</table>\n",
  "<p style='font-size: 0.85em; color: #718096; text-align: center; margin-top: 10px;'>",
  "HR < 1 favors column-defining treatment in lower triangle, and row-defining treatment in upper triangle.",
  "</p>\n</div>"
)

# 3. Export Formatted HTML File
writeLines(html_table, output_html)
cat(sprintf(" [SUCCESS] Exported formatted HTML league table to: %s\n\n", output_html))
