# ============================================================
# Malaria TPR + Settlement Type: Critical Thinking Lab Script
# ============================================================

library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(broom)
library(splines)

# --- 0) Choose outcome (swap if you want observed positivity)
OUTCOME <- "dummy_tpr"  # or "positivity"

# --- 1) Basic sanity checks (students must interpret these)
vars <- c(
  "classification",
  OUTCOME,
  "wealth_index", "median_age",
  "NDWI", "EVI", "temperature_c",
  "soil_moisture_index", "distance_to_water_m",
  "sanitation_index",
  "n_tested", "n_positive"
)

dat <- simulated_data %>%
  dplyr::select(any_of(vars)) %>%
  mutate(
    classification = as.factor(classification),
    log_dist_water = log(distance_to_water_m + 1)
  )

stopifnot(all(c(OUTCOME, "classification") %in% names(dat)))

cat("\n--- Missingness summary ---\n")
print(sapply(dat, function(x) sum(is.na(x))))

cat("\n--- Range checks ---\n")
rng <- dat %>%
  summarise(
    across(where(is.numeric),
           list(min = ~min(., na.rm = TRUE),
                max = ~max(., na.rm = TRUE)))
  )


print(rng)

# ------------------------------------------------------------
# SECTION A: Visualize group structure (settlement confounding)
# ------------------------------------------------------------

# A1) Outcome by settlement type
ggplot(dat, aes(x = classification, y = .data[[OUTCOME]])) +
  geom_boxplot() +
  labs(
    title = paste("Outcome by Settlement Class:", OUTCOME),
    x = "Settlement class (classification)",
    y = OUTCOME
  )

# A2) Covariates by settlement type (students see variables are partially "encoded" by class)
covars <- c("wealth_index", "median_age", "NDWI", "EVI", "temperature_c",
            "soil_moisture_index", "log_dist_water", "sanitation_index")

dat_long <- dat %>%
  pivot_longer(cols = all_of(covars), names_to = "variable", values_to = "value")

ggplot(dat_long, aes(x = classification, y = value)) +
  geom_boxplot(outlier.alpha = 0.3) +
  facet_wrap(~variable, scales = "free_y") +
  labs(
    title = "Distributions of covariates by settlement type (look for confounding!)",
    x = "classification",
    y = "value"
  )

# ---------------------------
# CRITICAL THINKING PROMPT #1
# ---------------------------
cat("
CRITICAL THINKING #1:
- If covariates differ strongly by classification AND outcome differs by classification,
  then classification may be a confounder.
- Question: Are we learning 'malaria risk drivers' or just re-discovering settlement class labels?
\n")

# ------------------------------------------------------------
# SECTION B: Naive (unadjusted) associations vs adjusted models
# ------------------------------------------------------------

# B1) Unadjusted linear models: outcome ~ covariate
unadj_results <- lapply(covars, function(v) {
  f <- as.formula(paste0(OUTCOME, " ~ ", v))
  m <- lm(f, data = dat)
  broom::tidy(m) %>%
    filter(term != "(Intercept)") %>%
    mutate(model = "unadjusted", covariate = v)
}) %>% bind_rows()

# B2) Adjusted for settlement type: outcome ~ covariate + classification
adj_results <- lapply(covars, function(v) {
  f <- as.formula(paste0(OUTCOME, " ~ ", v, " + classification"))
  m <- lm(f, data = dat)
  broom::tidy(m) %>%
    filter(term == v) %>%
    mutate(model = "adjusted_for_classification", covariate = v)
}) %>% bind_rows()

compare <- bind_rows(unadj_results, adj_results) %>%
  dplyr::select(model, covariate, estimate, std.error, statistic, p.value) %>%
  arrange(covariate, model)

cat("\n--- Unadjusted vs Adjusted (for classification) ---\n")
print(compare)

# ---------------------------
# CRITICAL THINKING PROMPT #2
# ---------------------------
cat("
CRITICAL THINKING #2:
- Compare unadjusted vs adjusted estimates.
- If a covariate 'loses significance' after adjusting for classification:
    * Does that mean it is not important?
    * Or does it mean the covariate's effect is mediated/encoded by settlement type?
- Write 2 interpretations for one covariate that changes a lot.
\n")

# ------------------------------------------------------------
# SECTION C: Multicollinearity (students must discover it)
# ------------------------------------------------------------

# C1) Correlation among numeric covariates
num_dat <- dat %>%
  dplyr::select(all_of(covars)) %>%
  st_drop_geometry() %>% 
  mutate(across(everything(), as.numeric))

cor_mat <- cor(num_dat, use = "pairwise.complete.obs")

# quick base heatmap (no extra packages)
op <- par(mar = c(8, 8, 2, 2))
image(1:ncol(cor_mat), 1:nrow(cor_mat), t(cor_mat)[, nrow(cor_mat):1],
      axes = FALSE, xlab = "", ylab = "",
      main = "Correlation heatmap: look for redundant variables")
axis(1, at = 1:ncol(cor_mat), labels = colnames(cor_mat), las = 2, cex.axis = 0.8)
axis(2, at = 1:nrow(cor_mat), labels = rev(rownames(cor_mat)), las = 2, cex.axis = 0.8)
par(op)

cat("
CRITICAL THINKING #3:
- Which pairs are highly correlated (|r| > 0.7)?
- If two variables track the same underlying construct, what happens in regression?
- Propose one remedy: remove one variable, PCA, ridge regression, or domain-based selection.
\n")

# ------------------------------------------------------------
# SECTION D: Nonlinearity (temperature is the teaching classic)
# ------------------------------------------------------------

# D1) Temperature effect: linear vs nonlinear spline
m_lin  <- lm(as.formula(paste0(OUTCOME, " ~ temperature_c + classification")), data = dat)
m_spl  <- lm(as.formula(paste0(OUTCOME, " ~ ns(temperature_c, df=3) + classification")), data = dat)

cat("\n--- Model comparison (temp linear vs spline) ---\n")
print(anova(m_lin, m_spl))

# plot fitted curve for temperature, holding classification constant (pick a reference class)
ref_class <- levels(dat$classification)[1]
grid <- tibble(
  temperature_c = seq(min(dat$temperature_c, na.rm = TRUE), max(dat$temperature_c, na.rm = TRUE), length.out = 200),
  classification = factor(ref_class, levels = levels(dat$classification))
)

grid$pred_lin <- predict(m_lin, newdata = grid)
grid$pred_spl <- predict(m_spl, newdata = grid)

ggplot(grid, aes(x = temperature_c)) +
  geom_line(aes(y = pred_lin)) +
  geom_line(aes(y = pred_spl), linetype = 2) +
  labs(
    title = paste("Temperature effect (holding classification =", ref_class, ")"),
    subtitle = "Solid = linear | Dashed = spline (nonlinear). Which is more plausible biologically?",
    x = "Temperature (°C)",
    y = paste("Predicted", OUTCOME)
  )

cat("
CRITICAL THINKING #4:
- Why might temperature have a non-linear relationship with malaria transmission?
- If a student fits only a linear model, what wrong conclusion could they draw?
\n")

# ------------------------------------------------------------
# SECTION E: Interaction (effects differ by settlement type)
# ------------------------------------------------------------

# E1) Does NDWI effect differ by settlement class?
m_int <- lm(as.formula(paste0(OUTCOME, " ~ NDWI * classification")), data = dat)

cat("\n--- Interaction model summary (NDWI * classification) ---\n")
print(summary(m_int))

cat("
CRITICAL THINKING #5:
- If NDWI has different effects across classes, what does that mean?
  * Mechanism differs? Measurement differs? Confounding? Model mis-specification?
- Pick one class where NDWI effect seems strongest and explain why (in words).
\n")

# ------------------------------------------------------------
# SECTION F: Predictive lens (forces humility about causality)
# ------------------------------------------------------------

# F1) Simple baseline predictive model including all covariates + class
m_full <- lm(as.formula(paste0(
  OUTCOME, " ~ wealth_index + sanitation_index + NDWI + EVI + soil_moisture_index + ",
  "log_dist_water + median_age + ns(temperature_c, df=3) + classification"
)), data = dat)

cat("\n--- Full model summary ---\n")
print(summary(m_full))

# F2) Compare to a model using ONLY classification (how much does class already explain?)
m_class_only <- lm(as.formula(paste0(OUTCOME, " ~ classification")), data = dat)

cat("\n--- R^2 comparison: class-only vs full ---\n")
cat("R^2 class-only:", summary(m_class_only)$r.squared, "\n")
cat("R^2 full      :", summary(m_full)$r.squared, "\n")

cat("
CRITICAL THINKING #6:
- If class-only already explains most of the variance, then:
  Are covariates adding 'new information' or just restating settlement type?
- What does that imply for causal interpretation?
\n")

# ------------------------------------------------------------
# SECTION G: Challenge tasks (students must write answers)
# ------------------------------------------------------------

cat("
===================== STUDENT CHALLENGE TASKS =====================

1) Confounding:
   - Pick ONE covariate where the unadjusted association differs greatly from the adjusted (for classification) association.
   - Explain how classification could be confounding this relationship.

2) Multicollinearity:
   - Identify the strongest correlated pair.
   - Fit two models: one with both variables, one with only one.
   - Compare coefficient stability and interpret.

3) Nonlinearity:
   - Using temperature, argue why a nonlinear model is more realistic.
   - Provide a short paragraph describing the consequence of using a linear-only model.

4) Mechanism vs Proxy:
   - Choose one variable (e.g., sanitation_index).
   - Is it a direct cause of malaria risk, or a proxy for broader infrastructure and wealth?
   - Justify your answer using your plots.

5) Fairness / Policy scenario:
   - If you used this model to target interventions, which variables might bias decisions against informal settlements?
   - What would you do to mitigate this in practice?

===================================================================
\n")

