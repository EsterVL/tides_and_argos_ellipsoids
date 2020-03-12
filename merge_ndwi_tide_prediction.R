#With this code you can estimate bathymetry based on NDWI 
#values in your satellite imagery brick and tide level prediction. 
#You have to do it separately for Flow and Ebb phases, 
#since the patterns of water flow differ between the phases.

#The inputs for this script 
library(raster)
library(rootSolve)
library(mgcv)
library(data.table)
library(SpaDES)
library(parallel)
library(snow)
library(rgdal)
source("edit_tables.R")
source('split_raster.R')
source('cross_gam_function_ER_1.R')

#Because cross_gam does not use extremums, I assign extremums to ebbb 
metadata_images_table$tide_phase<-ifelse(metadata_images_table$tide_next_point > metadata_images_table$z.m.,"flow","ebb")

#remove NAs
metadata_images_table<-metadata_images_table[!is.na(metadata_images_table$z.m.),]

#define maximal tide level for the data, and recalculate tide levels into meters to maximum
metadata_images_table$meters_to_max <- max(metadata_images_table$z.m.)-metadata_images_table$z.m.

#give tide levels at flow negative values
metadata_images_table$meters_to_max[metadata_images_table$tide_phase=='flow']<- -metadata_images_table$meters_to_max[metadata_images_table$tide_phase=='flow']

#create a brick
brk_tiff <- do.call(brick, lapply(metadata_tiff_table, raster))
writeRaster(brk_tiff, 'brk_tiff.grd', overwrite=TRUE)

#create brick files for ebb and flood
meters<-as.numeric(metadata_images_table$meters_to_max)
beginCluster(4)
cl <- getCluster()  
clusterExport(cl, "meters")

#the calc function itterates through a brickfile by itself, so the forloop was not necessary. 
#This also helps improve the running time
brk_ebb <- calc(brk_tiff, fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_ebb)} )
brk_flood <- calc(brk_tiff, fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_flow)} )

#split the brickfiles of flood and ebb into seperate images
tiles_Ebb <- splitRaster(brk_Ebb, nx=5, ny=5, )
tiles_Flood <- splitRaster(brk_Flood, nx=5, ny=5, )

#tests
plot(tiles_Ebb[[1]])
plot(tiles_Ebb[[4]])

tt <- tiles_Ebb[[4]]
values(tt)
