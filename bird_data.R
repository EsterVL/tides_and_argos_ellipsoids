library(raster)
library(data.table)
source("edit_tables.R")
Flood_raw<-brick('Flood_raw_Oman.grd')
Ebb_raw<-brick('Ebb_tides_Oman.grd')

#The birdlocation_table gets a collumn with the tide phases.
birdlocation_table$tide_phase<-ifelse(birdlocation_table$tide_next_point > birdlocation_table$z.m.,"flow","ebb")
# birdlocation_table<-birdlocation_table[!is.na(birdlocation_table$z.m.),]

#define maximal tide level for the data, and recalculate tide levels into meters to maximum
birdlocation_table$meters_to_max <- max(birdlocation_table$z.m.)-birdlocation_table$z.m.

#give tide levels at flow negative values
birdlocation_table$meters_to_max[birdlocation_table$tide_phase=='flow']<- -birdlocation_table$meters_to_max[birdlocation_table$tide_phase=='flow']

#split the bird location table in an abb table and a flood table
Ebb_birds_table <- birdlocation_table[(birdlocation_table$tide_phase=='ebb'),]
Flow_birds_table <-birdlocation_table[(birdlocation_table$tide_phase=='flow'),]

#compare the raw Ebb brick with the Ebb birds table. Extract the values
Ebb_birds <- SpatialPointsDataFrame(data.frame(Ebb_birds_table$location.long, Ebb_birds_table$location.lat), data.frame(Ebb_birds_table))
proj4string(Ebb_birds)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
Ebb_birds_table$tiff_value <- extract(Ebb_raw, Ebb_birds[,c(1,2)], cellnumbers=F)

#compare the raw Flow brick with the Flow birds table. Extract the values
Flow_birds <- SpatialPointsDataFrame(data.frame(Flow_birds_table$location.long, Flow_birds_table$location.lat), data.frame(Flow_birds_table))
proj4string(Flow_birds)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
Flow_birds_table$tiff_value <- extract(Flood_raw, Flow_birds[,c(1,2)], cellnumbers=F)

#For both the Ebb birds table and the Flow birds table, we determine if a bird is on land or in the water
#by comparing their tiff value to their meters to max value. 
#if an Ebb bird has a lower tiff value compared to their meters to max value, it is on water. 
#if an Ebb bird has a higher tiff value compared to their meters to max value, it is on land. 
#if an Flow bird has a higher tiff value compared to their meters to max value, it is on water. 
#if an Flow bird has a lower tiff value compared to their meters to max value, it is on land. 
Ebb_birds_table$enviroment<-ifelse(Ebb_birds_table$tiff_value < Ebb_birds_table$meters_to_max ,"water", ifelse(Ebb_birds_table$tiff_value > Ebb_birds_table$meters_to_max ,"land", NA))
Flow_birds_table$enviroment<-ifelse(Flow_birds_table$tiff_value > Flow_birds_table$meters_to_max ,"water", ifelse(Flow_birds_table$tiff_value < Flow_birds_table$meters_to_max ,"land", NA))

#all birds with NA's in the tiff_value collumn will be removed, because they are not in the designated area
Ebb_birds_table <- Ebb_birds_table[!is.na(Ebb_birds_table$tiff_value),]
Flow_birds_table <- Flow_birds_table[!is.na(Flow_birds_table$tiff_value),]




