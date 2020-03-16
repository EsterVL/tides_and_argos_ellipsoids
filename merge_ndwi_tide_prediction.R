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

#doing something with the meters to max collumn
meters<-as.numeric(metadata_images_table$meters_to_max)
beginCluster(10)
cl <- getCluster()  
clusterExport(cl, "meters")

#the brickfile is split into different images
tiles<-splitRaster(brk_tiff, nx=5, ny=5, )

ResE<-c()
ResF<-c()

#rasterfiles are created for the ebb and flow images
for (i in 1:length(tiles)) {
  cat(i, 'Ebb \n')
  Res_cur_E <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_ebb)} )
  plot(Res_cur_E)
  ResE<-c(ResE, Res_cur_E)
  cat(i, 'Flow \n')
  Res_cur_F <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_flow)} )
  plot(Res_cur_F)
  ResF<-c(ResF, Res_cur_F)
}
endCluster()

#create an ebb brick that can determine if a bird is on always land or always water
Ebb_raw <- do.call(merge, ResE)
writeRaster(Ebb_raw, 'Ebb_raw_Oman.grd')

#create an flood brick that can determine if a bird is on always land or always water
Flood_raw <- do.call(merge, ResF)
writeRaster(Flood_raw, 'Flood_raw_Oman.grd')

