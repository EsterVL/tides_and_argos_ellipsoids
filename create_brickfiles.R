#With this code you can estimate bathymetry based on NDWI 
#values in your satellite imagery brick and tide level prediction. 
#You have to do it separately for Flow and Ebb phases, 
#since the patterns of water flow differ between the phases.

#create a brick file of the tiff images
brk_tiff <- do.call(brick, lapply(metadata_tiff_table, raster))

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
  Res_cur_E <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_ebb)} )
  ResE<-c(ResE, Res_cur_E)
  Res_cur_F <- calc(tiles[[i]], fun=function(x){ parApply(cl, x, 1, cross_gam_wrapper_par_flow)} )
  ResF<-c(ResF, Res_cur_F)
}
endCluster()

#create an ebb brick that can determine if a bird is on always land or always water
Ebb_raw <- do.call(merge, ResE)
writeRaster(Ebb_raw, 'Ebb_raw_Oman.grd')

#create an flood brick that can determine if a bird is on always land or always water
Flood_raw <- do.call(merge, ResF)
writeRaster(Flood_raw, 'Flood_raw_Oman.grd')
