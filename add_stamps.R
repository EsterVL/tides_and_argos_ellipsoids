#This script is called upon by the script "Model_Bship.R"

##this script gives all the tables a propper timestamp and locationstamp

#Give all tables a propper timestamp
tides_table$timestamp <- strptime(tides_table$time, format='%m.%d.%Y %H:%M', tz = 'UTC')
birdlocation_table$timestamp <- strptime(birdlocation_table$timestamp, format='%Y-%m-%d %H:%M', tz = 'UTC')
metadata_images_table$timestamp <- strptime(metadata_images_table$timestamp, format='%Y-%m-%d-%H-%M', tz = 'UTC')

#Give the birds a proper locationstamp
positievogel <- SpatialPointsDataFrame(data.frame(birdlocation_table$location.long, birdlocation_table$location.lat), data.frame(birdlocation_table))
proj4string(positievogel)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")



