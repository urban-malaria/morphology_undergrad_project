rm(list=ls())


# packages to be used
list_of_packages <- c("RColorBrewer", "sf","dplyr", "ggpubr", "viridis",
                      "raster", "tidyr", "foreach", "doParallel", "stringr",
                      "rpart", "randomForest", "xgboost", "lightgbm","stats",
                       "ggplot2", "reshape")



read_install_pacakges <- function(packages = list_of_packages
){
  # installs or loads all packages 
  new_packages <- packages[!(list_of_packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new_packages)
  return(sapply(list_of_packages, require, character.only = TRUE))
}

read_install_pacakges()



#custom helper functions 

map_theme <- function(){
  theme(axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        rect = ggplot2::element_blank(),
        plot.background = ggplot2::element_rect(fill = "white", colour = NA), 
        plot.title = element_text(hjust = 0.5),
        legend.title=element_text(size=8, colour = 'black', hjust = 0.5), 
        legend.text =element_text(size = 8, colour = 'black'),
        legend.key.height = unit(0.65, "cm"))
}

theme_manuscript <- function(){
  theme_bw() + 
    theme(panel.border = element_rect(colour = "black", fill=NA, size=0.5),
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(size = 12, color = "black"), 
          axis.text.y = element_text(size = 12, color = "black"),
          axis.title.x = element_text(size = 12),
          axis.title.y = element_text(size =12),
          legend.title=element_text(size=12, colour = 'black'),
          legend.text =element_text(size = 12, colour = 'black'),
          legend.key.height = unit(1, "cm"))
}


#pathways 
shapefile <- file.path("data", "Agugu", "agugu_footprints.shp")
building_morphology <- file.path("data/Agugu_clustered_building_metrics.csv")
tpr_data <- file.path("data/ibhh_tprdf_a.csv")

agugu_shapefile <- st_read(shapefile)
agugu_morphology <- read.csv(building_morphology)




