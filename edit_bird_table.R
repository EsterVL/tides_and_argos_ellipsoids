#This script adds an extra collumn to the birdlocation table and tells if a bird is on land or in the water.

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
##if ebb:
##if meters to max of bird > ebb value of tiff: water
##if meters to max of bird < ebb value of tiff: land
##if flood:
##if meters to max of bird > flood value of tiff: land
##if meters to max of bird < flood value of tiff: water
Ebb_birds_table$enviroment<-ifelse(Ebb_birds_table$tiff_value > Ebb_birds_table$meters_to_max ,"water", ifelse(Ebb_birds_table$tiff_value < Ebb_birds_table$meters_to_max ,"land", NA))
Flow_birds_table$enviroment<-ifelse(Flow_birds_table$tiff_value < Flow_birds_table$meters_to_max ,"water", ifelse(Flow_birds_table$tiff_value > Flow_birds_table$meters_to_max ,"land", NA))

#all birds with NA's in the tiff_value collumn will be removed, because they are not in the designated area
Ebb_birds_table <- Ebb_birds_table[!is.na(Ebb_birds_table$enviroment),]
Flow_birds_table <- Flow_birds_table[!is.na(Flow_birds_table$enviroment),]

