#This script is called upon by the script "Model_Bship.R"

##this script will merge all the useful information from the tides table to the birdlocation and the
##metadata image table

#Merge the waterheight, tide phase and meters to max from the tides table to the birdlocation table
birdlocation_table <- merge(x=birdlocation_table, y=tides_table, by="timestamp", all.x=T, sort=F)

#Merge the waterheight, tide phase and meters to max from the tides table to the metadata images table
metadata_images_table <- merge(x=metadata_images_table, y=tides_table, by="timestamp", all.x=T, sort=F)
