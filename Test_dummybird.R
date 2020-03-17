library(maptools)
library(raster)
library(data.table)
source('edit_tables.R')
Flood_raw<-brick('Flood_raw_Oman.grd')
Ebb_raw <- brick('Ebb_raw_Oman.grd')


##check in birds table what the lowest and highest waterlevel are, what the corresponding meters
## to max are and at what time that are. 
lowest_tide <- tides_table[which.min(tides_table$z.m.), ]
mtm_low <- -(max(tides_table$z.m.) - lowest_tide$z.m.)
time_low <- lowest_tide$timestamp

highest_tide <- tides_table[which.max(tides_table$z.m.), ]
mtm_high <- -(max(tides_table$z.m.) - highest_tide$z.m.)
time_high <- highest_tide$timestamp

##location close the the coast
x <- 58.666492
y <- 20.694004

##make a dataframe low
df_low <- data.frame(time = time_low, mtm = mtm_low, x = x, y = y)
##make is spatial
coordinates(df_low) <- ~x+y
df_low.sp <- SpatialPointsDataFrame(coordinates(df_low), data.frame(df_low))
##wgs84 coordinates
proj4string(df_low.sp)= CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

##make a dataframe high
df_high <- data.frame(time = time_high, mtm = mtm_high, x = x, y = y)
##make is spatial
coordinates(df_high) <- ~x+y
df_high.sp <- SpatialPointsDataFrame(coordinates(df_high), data.frame(df_high))
##wgs84 coordinates
proj4string(df_high.sp)= CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#extract 4 tiff values, one for high ebb, one for high flood, one for low ebb, one for low flood
high_flood <- extract(Flood_raw, df_high.sp[,c(1,2)], cellnumbers=F)
high_ebb <- extract(Ebb_raw, df_high.sp[,c(1,2)], cellnumbers=F)
low_flood <- extract(Flood_raw, df_low.sp[,c(1,2)], cellnumbers=F)
low_ebb <- extract(Ebb_raw, df_low.sp[,c(1,2)], cellnumbers=F)

#check if bird is on land or on water
ifelse(low_flood < df_low$mtm ,"water", "land")
ifelse(low_ebb < df_low$mtm ,"water", "land")
ifelse(high_flood < df_high$mtm ,"water", "land")
ifelse(high_ebb > df_high$mtm ,"water", "land")
