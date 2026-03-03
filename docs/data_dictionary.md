# Data Dictionary

This document describes all variables used in the malaria–morphology dataset.

---
  
## Geographic and Identification Variables
  
  | Variable | Description |
  |--------|------------|
  | latitud | Latitude coordinate (decimal degrees) of the spatial unit centroid |
  | longitd | Longitude coordinate (decimal degrees) of the spatial unit centroid |
  | StateCd | State administrative code |
  | LGACode | Local Government Area (LGA) code |
  | WardCod | Ward code |
  | WardNam | Ward name |
  | Urban | Indicator for urban classification |
  | Source | Origin of the record |
  | Timstmp | Timestamp of data creation |
  | GloblID | Globally unique identifier |
  | AMAPCOD | Program-specific administrative code |
  | Id | Unique observation identifier |
  
  ---
  
## Morphological Variables (not simulated)
  
  | Variable | Description |
  |--------|------------|
  | area_mean | Mean building footprint area |
  | perimeter_mean | Mean building perimeter |
  | compact_mean | Mean building compactness index |
  | shape_mean | Mean building shape index |
  | angle_mean | Mean building orientation angle |
  | nndist_mean | Mean nearest-neighbor building distance |
  | nearest_sn | Nearest spatial neighbor identifier |
  | classification | Settlement morphology class |
  | geometry | Spatial geometry object |
  
  ---
  
## Malaria Outcomes
  
  | Variable | Description |
  |--------|------------|
  | n_tested | Number of individuals tested |
  | n_positive | Number testing positive |
  | positivity | Observed malaria positivity rate |
  | dummy_tpr | Simulated malaria test positivity rate (simulated for learning purposes) |
  
  ---
  
## Socio-Demographic Variables (simulated)
  
  | Variable | Description |
  |--------|------------|
  | wealth_index | Simulated household wealth index (0–1) |
  | median_age | Median age of the population |
  
  ---
  
## Environmental Variables (simulated)
  
  | Variable | Description |
  |--------|------------|
  | NDWI | Normalized Difference Water Index |
  | EVI | Enhanced Vegetation Index |
  | temperature_c | Ambient temperature (°C) |
  | soil_moisture_index | Soil moisture index (0–1) |
  | distance_to_water_m | Distance to nearest water body (meters) |
  | sanitation_index | Sanitation access index (0–1) |
  