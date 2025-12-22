source(libraries_and_paths.R)

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





ggplot(combined_with_tpr, aes(x = as.factor(classification), y = positivity)) +
  geom_boxplot() +
  labs(
    x = "Settlement Type",
    y = "Malaria Test Positivity",
    title = "Malaria Positivity by Settlement Type"
  )



