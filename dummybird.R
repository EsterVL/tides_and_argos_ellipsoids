##check in tides table what the lowest and highest waterlevel are, what the corresponding meters
## to max are and at what time that are. The corresponding meters to max are the new dummybirds.
dummybird_lowtide <- min(tides_table$meters_to_max)
dummybird_hightide <- max(tides_table$meters_to_max)

#getting the location of the dummybirds
loc <- data.frame(x = 58.666492, y = 20.694004)
coordinates(loc) <- ~x+y
loc <- SpatialPointsDataFrame(coordinates(loc), data.frame(loc))
proj4string(loc)= CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#extract the tiff values for ebb and flow. The coordinates for the dummybird high are used, but they are
#equal to the coordinates of the dummybird low, so it doesn't make a difference.
tiff_flood <- extract(Flood_raw, loc[,c(1,2)], cellnumbers=F)
tiff_ebb <- extract(Ebb_raw, loc[,c(1,2)], cellnumbers=F)

#determine which dummybird is in the water and which dummybird is on land
ifelse(tiff_flood < dummybird_hightide, "land", "water")
ifelse(tiff_flood > dummybird_lowtide, "water", "land")
ifelse(tiff_ebb < dummybird_hightide, "land", "water")
ifelse(tiff_ebb > dummybird_lowtide, "water", "land")









