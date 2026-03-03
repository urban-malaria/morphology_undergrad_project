# Project Rules and Guidelines

## Project Overview
This repository supports an undergraduate project analyzing settlement morphology and malaria risk in Agugu Ward, Ibadan, Nigeria. The project combines spatial analysis, building morphology metrics, and environmental covariates to explore relationships between settlement types and malaria test positivity rates.

---

## File Organization

### Directory Structure
- **`data/`**: Store all datasets (raw and processed). Do not edit raw files directly.
- **`docs/`**: Documentation files (data dictionaries, reports, etc.)
- **`literature/`**: Literature review materials and references
- **`*.R`**: Analysis scripts in the root directory

### File Naming Conventions
- Use lowercase with underscores: `data_wrangling.R`, `data_exploration.R`
- Data files: descriptive names matching their content (e.g., `analysis_data.csv`)
- Scripts: verb-based names indicating purpose (e.g., `data_wrangling.R`, `data_exploration.R`)

---

## R Coding Standards

### Package Management
- **Always source `libraries_and_paths.R` first** in analysis scripts
- Load packages at the top of scripts using `library()` calls
- Use `libraries_and_paths.R` for centralized package loading and path definitions
- Document any new package dependencies in `libraries_and_paths.R`

### Path Management
- Define file paths in `libraries_and_paths.R` using `file.path()` for cross-platform compatibility
- Use relative paths from project root
- Example:
  ```r
  shapefile <- file.path("data", "Agugu", "agugu_footprints.shp")
  ```

### Code Style
- Use **tidyverse** style conventions (`dplyr`, `ggplot2`, `tidyr`)
- Prefer pipes (`%>%`) for data transformations
- Use meaningful variable names (avoid abbreviations unless standard)
- Add comments for complex operations, especially spatial joins and transformations
- Set random seeds (`set.seed()`) when using random number generation

### Spatial Data Handling
- Always specify CRS explicitly when reading spatial data
- Use `st_transform()` to convert to metric CRS (e.g., UTM Zone 31N: `32631`) for distance calculations
- Keep original CRS (`4326` for lat/lon) when appropriate
- Use `sf` package for spatial operations
- Document coordinate system transformations with comments

### Data Wrangling
- Use `dplyr::select()` with `any_of()` when selecting variables that may not exist
- Prefer `mutate()` over base R assignment for creating new variables
- Use `case_when()` for conditional variable creation
- Check for missing values and document handling approach
- Validate data ranges and types after transformations

---

## Data Management

### Raw Data
- **Never modify raw data files directly**
- Create derived/processed datasets with descriptive names
- Document transformations in scripts or data dictionaries
- Store processed data in `data/` directory

### Data Outputs
- Save processed datasets to `data/` directory
- Use descriptive filenames (e.g., `analysis_data.csv`)
- Include metadata or documentation for derived datasets
- Update `docs/data_dictionary.md` when adding new variables

### Data Dictionary
- Maintain `docs/data_dictionary.md` with all variables used in analysis
- Document variable types, ranges, units, and sources
- Include notes on simulated vs. observed variables

---

## Analysis Scripts

### Script Structure
1. **Source libraries and paths**: `source("libraries_and_paths.R")`
2. **Set random seed** (if using randomization)
3. **Load data**: Read from paths defined in `libraries_and_paths.R`
4. **Data processing**: Transformations, joins, feature engineering
5. **Analysis**: Statistical tests, models, visualizations
6. **Output**: Save results, figures, processed data

### Script Organization
- Keep data wrangling separate from exploration/analysis when possible
- Use clear section headers with comments
- Group related operations together
- Document assumptions and methodological choices

### Variable Naming
- Use descriptive names: `n_tested`, `positivity`, `classification`
- Follow consistent naming patterns (e.g., `*_mean`, `*_index`)
- Document variable creation logic in comments

---

## Visualization

### ggplot2 Standards
- Use custom themes from `libraries_and_paths.R` (`map_theme()`, `theme_manuscript()`)
- Consistent color schemes (consider `viridis` for continuous variables)
- Clear axis labels and titles
- Save figures with descriptive names (e.g., `error_distribution_improved.png`)

### Figure Naming
- Use descriptive names indicating content
- Include version indicators if iterating (e.g., `*_improved.png`)
- Store figures in project root or dedicated `figures/` directory

---

## Git Workflow

### Commit Practices
- Commit related changes together (e.g., data wrangling script + processed data)
- Use descriptive commit messages
- Do not commit temporary exploration scripts unless they're part of deliverables
- Keep `data_exploration.R` uncommitted if it's for iterative analysis

### File Tracking
- Add processed data files that are essential for reproducibility
- Exclude large raw files if necessary (use `.gitignore`)
- Commit documentation updates with corresponding code changes

---

## Documentation

### README.md
- Keep `README.md` updated with project structure and purpose
- Document directory purposes and conventions
- Include setup instructions if needed

### Code Comments
- Comment complex spatial operations (joins, transformations, CRS changes)
- Explain simulation logic and parameter choices
- Document data source assumptions

### Data Dictionary
- Maintain comprehensive variable documentation
- Distinguish between observed and simulated variables
- Include units, ranges, and data types

---

## Best Practices

### Reproducibility
- Set random seeds for simulations
- Use relative paths
- Document package versions if critical
- Save intermediate datasets for reproducibility

### Error Handling
- Validate data after loading (check for expected columns, ranges)
- Use `stopifnot()` for critical assumptions
- Check for missing values before analysis
- Document known data limitations

### Performance
- Use `sf` for spatial operations (not `sp`)
- Consider `data.table` for large datasets if needed
- Profile code if performance is an issue

### Collaboration
- Keep scripts modular and well-documented
- Use consistent coding style across scripts
- Document any deviations from standard practices

---

## Project-Specific Notes

### Settlement Classification
- `classification` variable represents settlement morphology clusters (0-8)
- Document classification methodology if creating new clusters
- Be aware of confounding between classification and other covariates

### Simulated Variables
- Many covariates are simulated for educational purposes
- Clearly label simulated variables (e.g., `dummy_tpr`, `wealth_index`)
- Document simulation logic and parameter ranges

### Malaria Outcomes
- `positivity`: Observed malaria test positivity rate
- `dummy_tpr`: Simulated test positivity rate (for learning)
- `n_tested`, `n_positive`: Testing counts
- Use appropriate outcome variable based on analysis goals

---

## Questions or Issues?
When in doubt:
1. Check existing scripts for patterns
2. Review `libraries_and_paths.R` for available utilities
3. Consult `docs/data_dictionary.md` for variable definitions
4. Follow tidyverse and sf package conventions
