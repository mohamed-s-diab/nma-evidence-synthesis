# Computational Reproducibility & Environment Documentation

## Overview
This document provides complete computational environment metadata, package version pinning, and procedural instructions to guarantee deterministic, exact reproduction of all 12 Network Meta-Analysis (NMA) analytical engines and 14 publication figure designs.

Compliant with:
- **ICMJE** Guidelines on Data Sharing and Computational Transparency
- **PRISMA-NMA** Extension Checklist (Item 23 & Item 24)
- **Cochrane Handbook for Systematic Reviews of Interventions** (Section 11.6)

---

## 1. Primary Computing Environment

| Attribute | Specification |
| :--- | :--- |
| **Statistical Language** | R version 4.6.1 (2026-06-24 ucrt) |
| **Platform** | `x86_64-w64-mingw32/x64` (64-bit Windows) |
| **Operating System** | Windows 10 x64 (build 19045) |
| **Matrix Algebra / LAPACK** | OpenBLAS / Standard LAPACK v3.12.1 |
| **Random Number Generator** | `Mersenne-Twister` with deterministic seeds |
| **Global Monte Carlo Seed** | `set.seed(42)` (10,000 draws for SUCRA and MCID engines) |

---

## 2. Core Statistical & Graphics Packages Manifest

| Package | Version | Primary Purpose in Portfolio |
| :--- | :---: | :--- |
| **`netmeta`** | **`3.6-1`** | Frequentist graph-theoretical NMA, Laplacian matrix inversion, P-scores, netsplit, netheat, CNMA, and metaregression |
| **`meta`** | **`8.5-0`** | Base meta-analysis algorithms, pairwise contrast math, and Egger publication bias tests |
| **`MASS`** | **`7.3-65`** | High-dimensional multivariate normal random variate generation (`mvrnorm`) |
| **`ggplot2`** | **`4.0.3`** | Visual grammar for 14 publication-grade figures at 300 DPI |
| **`patchwork`** | **`1.3.2`** | Multi-panel composite layout orchestration (Dual Forest, Funnel+Egger, MCID Framework) |
| **`dplyr`** | **`1.2.1`** | Data wrangling, contrast transformation, and rank probability table structuring |
| **`tidyr`** | **`1.3.2`** | Reshaping covariance arrays, rank matrices, and long-format plotting tables |
| **`rmarkdown`** | **`2.31`** | Automated dynamic report generation for HTML/PDF artifacts |
| **`knitr`** | **`1.51`** | Dynamic report chunk execution, caching, and kable table rendering |

---

## 3. Step-by-Step Reproduction Instructions

### Option A: One-Click Cloud Reproduction (Zero Installation)
Launch the fully configured, hermetic computational laboratory directly in your browser:

[![Open in GitHub Codespaces](https://img.shields.io/badge/Codespaces-Open%20in%20Cloud%20(One--Click)-238636.svg?style=for-the-badge&logo=github&logoColor=white)](https://codespaces.new/mohamed-s-diab/nma-nsclc-evidence-synthesis?quickstart=1)

Within ~30 seconds, an interactive cloud workspace will initialize with R 4.6.1, `netmeta`, Linux system headers (`libglpk-dev`), and all 86 locked dependencies ready to execute.

---

### Option B: Local Machine Execution
To execute the entire production pipeline and re-estimate all 12 analytical models, 14 summary tables, and 14 high-resolution figures locally:

1. Open PowerShell, Terminal, or Command Prompt in the repository root directory:
   ```bash
   cd path/to/nma_project
   ```

2. Restore the exact locked R computational environment:
   ```bash
   Rscript -e "install.packages('renv'); renv::restore(prompt = FALSE)"
   ```

3. Run the automated 18-step pipeline integrity and quality verification suite:
   ```bash
   Rscript tests/test_pipeline_integrity.R
   ```

4. Run the master orchestrator script:
   ```powershell
   Rscript scripts/run_all_pipeline.R
   ```

5. To compile the interactive HTML publication report:
   ```powershell
   Rscript -e "rmarkdown::render('report/nma_comprehensive_report.Rmd')"
   ```

All outputs will be generated into the standardized directories:
- `outputs/models/` (Serialized `.rds` cache objects)
- `outputs/tables/` (Summary CSVs and interactive HTML league tables)
- `outputs/figures/` (14 publication figures at 300 DPI)

---

## 4. Complete `sessionInfo()` Diagnostic Dump

```text
R version 4.6.1 (2026-06-24 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 10 x64 (build 19045)

Matrix products: default
LAPACK version 3.12.1

locale:
[1] LC_COLLATE=Arabic_Egypt.utf8  LC_CTYPE=Arabic_Egypt.utf8   
[3] LC_MONETARY=Arabic_Egypt.utf8 LC_NUMERIC=C                 
[5] LC_TIME=Arabic_Egypt.utf8    

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] knitr_1.51      rmarkdown_2.31  patchwork_1.3.2 tidyr_1.3.2    
 [5] dplyr_1.2.1     ggplot2_4.0.3   MASS_7.3-65     netmeta_3.6-1  
 [9] meta_8.5-0      metabook_0.2-0 

loaded via a namespace (and not attached):
 [1] gtable_0.3.6        xfun_0.59           ggrepel_0.9.8      
 [4] CompQuadForm_1.4.4  lattice_0.22-9      mathjaxr_2.0-0     
 [7] tzdb_0.5.0          numDeriv_2016.8-1.1 vctrs_0.7.3        
[10] tools_4.6.1         Rdpack_2.6.6        generics_0.1.4     
[13] tibble_3.3.1        pkgconfig_2.0.3     Matrix_1.7-5       
[16] RColorBrewer_1.1-3  S7_0.2.2            lifecycle_1.0.5    
[19] compiler_4.6.1      farver_2.1.2        stringr_1.6.0      
[22] htmltools_0.5.9     pillar_1.11.1       nloptr_2.2.1       
[25] reformulas_0.4.4    metadat_1.6-0       boot_1.3-32        
[28] abind_1.4-8         nlme_3.1-169        tidyselect_1.2.1   
[31] digest_0.6.39       mvtnorm_1.4-1       stringi_1.8.7      
[34] purrr_1.2.2         splines_4.6.1       magic_1.6-1        
[37] fastmap_1.2.0       colorspace_2.1-2    cli_3.6.6          
[40] metafor_5.0-1       magrittr_2.0.5      dichromat_2.0-0.1  
[43] readr_2.2.0         withr_3.0.3         scales_1.4.0       
[46] otel_0.2.0          igraph_2.3.3        lme4_2.0-1         
[49] hms_1.1.4           evaluate_1.0.5      rbibutils_2.4.1    
[52] rlang_1.3.0         Rcpp_1.1.1-1.1      glue_1.8.1         
[55] xml2_1.6.0          minqa_1.2.8         R6_2.6.1           
```
