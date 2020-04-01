#This script is called upon by the script "Model_Bship.R"

##four brickfiles are created that simulate ebb and flood. There are two ebb images and two flood images. 
##The difference between the two ebb and flood images, is the NDWI threshold, used to determine if a
##square is water or not. A threshold of 0.16 is used and a threshold of 0.30 is used.

##Eldar and Julia:
#"With this code you can estimate bathymetry based on NDWI 
#values in your satellite imagery brick and tide level prediction. 
#You have to do it separately for Flow and Ebb phases, 
#since the patterns of water flow differ between the phases."

#create a brick file of the tiff images
brk_tiff <- do.call(brick, lapply(metadata_tiff_table, raster))

#doing something with the meters to max collumn
meters<-as.numeric(metadata_images_table$meters_to_max)
beginCluster(10)
cl <- getCluster()  
clusterExport(cl, "meters")

#the brickfile is split into tiles, to make it easier on the computer
tiles<-splitRaster(brk_tiff, nx=5, ny=5, )

#empty lists are created for all four images
ResE_16<-c()
ResF_16<-c()
ResE_30<-c()
ResF_30<-c()

#rasterfiles are created for the ebb and flow images that are created with a 0.16 NDWI threshold
#and with a 0.30 NDWI threshold.
for (i in 1:length(tiles)) {
  Res_cur_E_16 <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_ebb_16)} )
  ResE_16<-c(ResE_16, Res_cur_E_16)
  print("1")
  Res_cur_F_16 <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_flow_16)} )
  ResF_16<-c(ResF_16, Res_cur_F_16)
  print("2")
  Res_cur_E_30 <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_ebb_30)} )
  ResE_30<-c(ResE_30, Res_cur_E_30)
  print("3")
  Res_cur_F_30 <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_flow_30)} )
  ResF_30<-c(ResF_30, Res_cur_F_30)
  print("4")
}
endCluster()

#create an ebb brick that can determine if a bird is on land or on water with a 0.16 NDWI threshold.
Ebb_16 <- do.call(merge, ResE_16)
writeRaster(Ebb_16, 'Ebb_16.grd')

#create an flood brick that can determine if a bird is on land or on water with a 0.16 NDWI threshold.
Flood_16 <- do.call(merge, ResF_16)
writeRaster(Flood_16, 'Flood_16.grd')

#create an ebb brick that can determine if a bird is on land or on water with a 0.30 NDWI threshold.
Ebb_30 <- do.call(merge, ResE_30)
writeRaster(Ebb_30, 'Ebb_30.grd')

#create an flood brick that can determine if a bird is on land or on water with a 0.30 NDWI threshold.
Flood_30 <- do.call(merge, ResF_30)
writeRaster(Flood_30, 'Flood_30.grd')
