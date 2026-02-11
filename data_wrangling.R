source("libraries_and_paths.R")
set.seed(123)

agugu_shapefile <- st_read(shapefile)
agugu_morphology <- read.csv(building_morphology)
agugu_tpr <- read.csv(tpr_data)

combined_data <- bind_cols(agugu_shapefile, agugu_morphology)



# 1. Convert agugu_tpr to sf
agugu_sf <- st_as_sf(
  agugu_tpr,
  coords = c("lon", "lat"),
  crs = 4326,
  remove = FALSE
)

# 2. Convert combined_data to sf
combined_sf <- st_as_sf(
  combined_data,
  coords = c("longitd", "latitud"),
  crs = 4326,
  remove = FALSE
)

# 3. (IMPORTANT) Project to a metric CRS for distance-based operations
# UTM Zone 31N (Nigeria)
agugu_sf_m <- st_transform(agugu_sf, 32631)      
combined_sf_m <- st_transform(combined_sf, 32631)

# 4. Find nearest Agugu TPR point for each combined_data point
nearest_idx <- st_nearest_feature(combined_sf_m, agugu_sf_m)

# 5. Bind nearest TPR attributes
combined_with_tpr <- combined_sf_m %>%
  mutate(
    nearest_sn = agugu_sf_m$sn[nearest_idx],
    n_tested   = agugu_sf_m$n_tested[nearest_idx],
    n_positive = agugu_sf_m$n_positive[nearest_idx],
    positivity = agugu_sf_m$positivity[nearest_idx]
  ) %>% 
  rowwise() %>%
  mutate(
    dummy_tpr = case_when(
      classification == 8 ~ sample(seq(0.5, 1.0, length.out = 100), 1),
      classification == 7 ~ sample(seq(0.1, 0.5, length.out = 100), 1),
      classification == 6 ~ sample(seq(0.0, 0.1, length.out = 100), 1),
      classification == 5 ~ sample(seq(0.1, 0.5, length.out = 100), 1),
      classification == 4 ~ sample(seq(0.5, 0.6, length.out = 100), 1),
      classification == 3 ~ sample(seq(0.4, 0.8, length.out = 100), 1),
      classification == 2 ~ sample(seq(0.5, 0.6, length.out = 100), 1),
      classification == 1 ~ sample(seq(0.1, 0.5, length.out = 100), 1),
      classification == 0 ~ sample(seq(0.1, 0.5, length.out = 100), 1),
      TRUE ~ NA_real_
    )
  ) %>%
  ungroup()



simulated_data <- combined_with_tpr %>%
  mutate(
    
    # 1. Wealth index (0–1): higher TPR -> lower wealth
    wealth_index = case_when(
      classification == 8 ~ sample(seq(0.05, 0.30, length.out = 50), 1),
      classification == 7 ~ sample(seq(0.20, 0.45, length.out = 50), 1),
      classification == 6 ~ sample(seq(0.70, 0.95, length.out = 50), 1),
      classification == 5 ~ sample(seq(0.35, 0.60, length.out = 50), 1),
      classification == 4 ~ sample(seq(0.25, 0.45, length.out = 50), 1),
      classification == 3 ~ sample(seq(0.15, 0.40, length.out = 50), 1),
      classification == 2 ~ sample(seq(0.30, 0.55, length.out = 50), 1),
      classification == 1 ~ sample(seq(0.40, 0.70, length.out = 50), 1),
      classification == 0 ~ sample(seq(0.45, 0.80, length.out = 50), 1),
      TRUE ~ NA_real_
    ),
    
    # 2. Median age (years): higher TPR -> younger population
    median_age = case_when(
      classification == 8 ~ sample(25:38, 1),
      classification == 7 ~ sample(18:65, 1),
      classification == 6 ~ sample(25:55, 1),
      classification == 5 ~ sample(20:58, 1),
      classification == 4 ~ sample(18:55, 1),
      classification == 3 ~ sample(17:74, 1),
      classification == 2 ~ sample(20:30, 1),
      classification == 1 ~ sample(22:35, 1),
      classification == 0 ~ sample(24:38, 1),
      TRUE ~ NA_real_
    ),
    
    # 3. NDWI: higher -> wetter -> higher malaria risk
    NDWI = case_when(
      classification == 8 ~ sample(seq(0.30, 0.70, length.out = 50), 1),
      classification == 7 ~ sample(seq(0.15, 0.50, length.out = 50), 1),
      classification == 6 ~ sample(seq(-0.30, 0.05, length.out = 50), 1),
      classification == 5 ~ sample(seq(0.05, 0.30, length.out = 50), 1),
      classification == 4 ~ sample(seq(0.10, 0.35, length.out = 50), 1),
      classification == 3 ~ sample(seq(0.20, 0.55, length.out = 50), 1),
      classification == 2 ~ sample(seq(0.05, 0.25, length.out = 50), 1),
      classification == 1 ~ sample(seq(-0.10, 0.20, length.out = 50), 1),
      classification == 0 ~ sample(seq(-0.15, 0.15, length.out = 50), 1),
      TRUE ~ NA_real_
    ),
    
    # 4. EVI: vegetation / humidity proxy
    EVI = case_when(
      classification == 8 ~ sample(seq(0.35, 0.65, length.out = 50), 1),
      classification == 7 ~ sample(seq(0.25, 0.50, length.out = 50), 1),
      classification == 6 ~ sample(seq(0.05, 0.20, length.out = 50), 1),
      classification == 5 ~ sample(seq(0.15, 0.35, length.out = 50), 1),
      classification == 4 ~ sample(seq(0.20, 0.40, length.out = 50), 1),
      classification == 3 ~ sample(seq(0.30, 0.55, length.out = 50), 1),
      classification == 2 ~ sample(seq(0.15, 0.30, length.out = 50), 1),
      classification == 1 ~ sample(seq(0.10, 0.25, length.out = 50), 1),
      classification == 0 ~ sample(seq(0.08, 0.22, length.out = 50), 1),
      TRUE ~ NA_real_
    ),
    
    # 5. Temperature (°C): optimal malaria transmission ~24–31
    temperature_c = case_when(
      classification == 8 ~ sample(seq(25, 30, length.out = 30), 1),
      classification == 7 ~ sample(seq(24, 31, length.out = 30), 1),
      classification == 6 ~ sample(seq(32, 35, length.out = 30), 1),
      classification == 5 ~ sample(seq(23, 30, length.out = 30), 1),
      classification == 4 ~ sample(seq(24, 29, length.out = 30), 1),
      classification == 3 ~ sample(seq(25, 31, length.out = 30), 1),
      classification == 2 ~ sample(seq(23, 29, length.out = 30), 1),
      classification == 1 ~ sample(seq(22, 30, length.out = 30), 1),
      classification == 0 ~ sample(seq(21, 29, length.out = 30), 1),
      TRUE ~ NA_real_
    ),
    
    # 6. Soil moisture index (0–1)
    soil_moisture_index = case_when(
      classification == 8 ~ sample(seq(0.50, 0.85, length.out = 50), 1),
      classification == 7 ~ sample(seq(0.35, 0.70, length.out = 50), 1),
      classification == 6 ~ sample(seq(0.05, 0.20, length.out = 50), 1),
      classification == 5 ~ sample(seq(0.20, 0.45, length.out = 50), 1),
      classification == 4 ~ sample(seq(0.25, 0.50, length.out = 50), 1),
      classification == 3 ~ sample(seq(0.40, 0.65, length.out = 50), 1),
      classification == 2 ~ sample(seq(0.20, 0.40, length.out = 50), 1),
      classification == 1 ~ sample(seq(0.15, 0.35, length.out = 50), 1),
      classification == 0 ~ sample(seq(0.10, 0.30, length.out = 50), 1),
      TRUE ~ NA_real_
    ),
    
    # 7. Distance to water bodies (meters): closer -> higher risk
    distance_to_water_m = case_when(
      classification == 8 ~ sample(seq(50, 500, length.out = 50), 1),
      classification == 7 ~ sample(seq(200, 1200, length.out = 50), 1),
      classification == 6 ~ sample(seq(2000, 5000, length.out = 50), 1),
      classification == 5 ~ sample(seq(800, 2500, length.out = 50), 1),
      classification == 4 ~ sample(seq(500, 2000, length.out = 50), 1),
      classification == 3 ~ sample(seq(300, 1500, length.out = 50), 1),
      classification == 2 ~ sample(seq(700, 2500, length.out = 50), 1),
      classification == 1 ~ sample(seq(1000, 3500, length.out = 50), 1),
      classification == 0 ~ sample(seq(1200, 4000, length.out = 50), 1),
      TRUE ~ NA_real_
    ),
    
    # 8. Sanitation index (0–1): better sanitation -> lower malaria
    sanitation_index = case_when(
      classification == 8 ~ sample(seq(0.05, 0.30, length.out = 50), 1),
      classification == 7 ~ sample(seq(0.20, 0.45, length.out = 50), 1),
      classification == 6 ~ sample(seq(0.75, 0.95, length.out = 50), 1),
      classification == 5 ~ sample(seq(0.40, 0.65, length.out = 50), 1),
      classification == 4 ~ sample(seq(0.35, 0.60, length.out = 50), 1),
      classification == 3 ~ sample(seq(0.15, 0.40, length.out = 50), 1),
      classification == 2 ~ sample(seq(0.45, 0.70, length.out = 50), 1),
      classification == 1 ~ sample(seq(0.55, 0.80, length.out = 50), 1),
      classification == 0 ~ sample(seq(0.60, 0.90, length.out = 50), 1),
      TRUE ~ NA_real_
    )
  ) %>%
  ungroup()




ggplot(combined_with_tpr, aes(x = as.factor(classification), y = dummy_tpr)) +
  geom_boxplot() +
  labs(
    x = "Settlement Type",
    y = "Malaria Test Positivity",
    title = "Malaria Positivity by Settlement Type"
  )




write.csv(simulated_data, "data/analysis_data.csv")

