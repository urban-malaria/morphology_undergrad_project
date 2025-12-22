# Settlement Types & Malaria Risk (Agugu Ward, Ibadan) — Undergraduate Project Repo

This repository supports an undergraduate project that combines:
1) a **literature review** on settlement types and disease risk in LMIC urban settings, and  
2) a **hands-on analysis** using building morphology + environmental covariates to explore how **settlement types (clusters)** relate to **malaria test positivity (TPR)** in **Agugu Ward, Ibadan (Nigeria)**.

Students will:
- review literature on **formal/informal/transition** settlement types and disease spread,
- run a simple clustering workflow (or use pre-generated clusters),
- perform exploratory analysis linking settlement types to TPR,
- run a **Kruskal–Wallis test** to support the visual evidence, and
- identify potential **hotspots**.

---

### `data/`
**Purpose:** Store datasets used in the analysis.  
Typical contents may include:
- building morphology metrics (e.g., area, perimeter, compactness, density),
- environmental covariates (e.g., NDVI/EVI, distance to water),
- malaria testing/TPR tables (e.g., `n_tested`, `n_positive`, `positivity`),
- optional spatial files (ward boundary, grids, shapefiles, geojson).

**Important notes:**
- Do not edit raw files directly. If you need to modify data, create a derived file and document it.
- Large files should be excluded from Git if necessary (see `.gitignore`).

---

### `literature/`
**Purpose:** Starting literature for the literature review component.  
Suggested use:
- Students should read and summarize core papers here.
- Add a short annotated bibliography (optional) as part of the deliverables.


### `libraries_and_paths.R`
**Purpose:** Central place to load packages and define file paths.

**What it should contain:**
- `library()` calls (e.g., `sf`, `dplyr`, `ggplot2`, `readr`, `data.table`)
- path definitions such as:
  - `DATA_DIR <- "data"`
  - `LIT_DIR  <- "literature"`
  - output folder paths if used (e.g., `outputs/figures`)

**Why this is useful:**
- Keeps the analysis scripts clean and consistent.
- Reduces “it works on my machine” issues.

**How to use:**
Run this first in your R session:
```r
source("libraries_and_paths.R")

