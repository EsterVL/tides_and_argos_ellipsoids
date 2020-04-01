#This script is called upon by the script "Model_Bship.R"

##check in tides table what the lowest and highest waterlevel are, what the corresponding meters
## to max are and at what time that are. The corresponding meters to max are the new dummybirds.
dummybird_lowtide <- min(tides_table$meters_to_max)
dummybird_hightide <- max(tides_table$meters_to_max)

##creating temporary location table to convert to spatialpointsdataframe
spdf <- loc

#getting the location of the dummybirds
spdf <- data.frame(x = 58.666492, y = 20.694004)
coordinates(spdf) <- ~x+y
spdf <- SpatialPointsDataFrame(coordinates(spdf), data.frame(spdf))
proj4string(spdf)= CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#extract the tiff values for ebb and flow. The coordinates for the dummybird high are used, but they are
#equal to the coordinates of the dummybird low, so it doesn't make a difference.
tiff_flood <- extract(Flood_raw, spdf[,c(1,2)], cellnumbers=F)
tiff_ebb <- extract(Ebb_raw, spdf[,c(1,2)], cellnumbers=F)

#determine which dummybird is in the water and which dummybird is on land
##if ebb:
##if meters to max > ebb value: water
ebb_water <- ifelse(dummybird_hightide > tiff_ebb, "expected = water","not expected = land")
##if meters to max < ebb value: land
ebb_land<- ifelse(dummybird_lowtide < tiff_ebb, "expected = land","not expected = water")
##if flood:
##if meters to max > flood value: land
flood_land <- ifelse(dummybird_hightide > tiff_flood, "expected = land","not expected = water")
##if meters to max < flood value: water
flood_water <- ifelse(dummybird_lowtide < tiff_flood, "expected = water","not expected = land")


print(ebb_water)
print(ebb_land)
print(flood_land)
print(flood_water)






