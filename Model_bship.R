##This script calls uppon all the different scripts and imports 
##all the packages and tables that are needed for the model

#the packages and functions nessecary to run the model
library(raster)
library(rootSolve)
library(mgcv)
library(data.table)
library(SpaDES)
library(parallel)
library(snow)
library(rgdal)
library(lubridate)
source('split_raster.R')
source('cross_gam_function.R')

#The tables nessecary to run the model
tides_table <- read.csv("tables/oman_tides_2016_2020.txt", sep="")
birdlocation_table <- read.csv("tables/BarWitsOman_Winter2016.csv")
metadata_tiff_table <- list.files(path = "tiff_images", pattern='local_tidal_level_*', full.names=TRUE)
checkpoints <- list.files(path = "tables", pattern="Stat*", full.names = TRUE)
loc <- read.csv("tables/station_field_data.csv")
tides_table_2011 <- read.csv("tables/oman_tides_2011.txt", sep = "")
#creating metadata_image_table
File_numbers<-as.numeric(sapply(strsplit(metadata_tiff_table, '_'), '[[', i=5))
tt<-sapply(strsplit(metadata_tiff_table, '_'), '[[', i=6)
File_date<-unlist(strsplit(tt, '[.]'))[which(unlist(strsplit(tt, '[.]')) != "tif")]
metadata_images_table <- data.frame(File_numbers, File_date)
names(metadata_images_table)<- c("image_number", "timestamp")


#This script edits tides_table in a way that all the useful information is available
source("edit_tides_table.R")

#This script gives all the tables a propper location- and timestamp
source("add_stamps.R")

#This script adds all the tide information from the tides table, to the birdlocation and the metadata images tables
source("merge_tables.R")

##four brickfiles are created that simulate ebb and flood. There are two ebb images and two flood images. 
##The difference between the two ebb and flood images, is the NDWI threshold, used to determine if a
##square is water or not. A threshold of 0.16 is used and a threshold of 0.30 is used.
#source("create_brickfiles.R")
#if brickfiles already exist, use this code to save time:
Flood_16<-brick('Flood_16.grd')
Ebb_16<-brick('Ebb_16.grd')
Flood_30<-brick('Flood_30.grd')
Ebb_30<-brick('Ebb_30.grd')

# For the brickfiles with the 0.16 threshold
Ebb_raw <- Ebb_16
Ebb_raw[Ebb_raw>=99]<-NA
Ebb_raw[Ebb_raw<=-99]<-NA
Flood_raw <- Flood_16
Flood_raw[Flood_raw>=99]<-NA
Flood_raw[Flood_raw<=-99]<-NA

#This script creates two new tables. One table with the information about the birds that are present during ebb
#and one table with the information about the birds that are present during flood. Both tables also have an
#extra column compared to the birdlocation table. This collumn tells if a bird is on land or in the water.
source("edit_bird_table.R")

#this script creates useful craphs from the flow birds table and the ebb birds table
source("creating_graphs.R")

# CHECKING THE MODEL
#This script creates 4 dummybirds to check if the model works
##if ebb:
##if bird_value > ebb value: water
##if bird_value < ebb value: land
##if flood:
##if bird_value > flood value: land
##if bird_value < flood value: water
source("dummybird.R")
#This script uses a very accurate measuring instrument to check how accurate the model is with predicting
#the presence of water and land on a position.
source("check_accuracy.R")

# For the brickfiles with the 0.30 threshold
Ebb_raw <- Ebb_30
Ebb_raw[Ebb_raw>=99]<-NA
Ebb_raw[Ebb_raw<=-99]<-NA
Flood_raw <- Flood_30
Flood_raw[Flood_raw>=99]<-NA
Flood_raw[Flood_raw<=-99]<-NA

#This script creates two new tables. One table with the information about the birds that are present during ebb
#and one table with the information about the birds that are present during flood. Both tables also have an
#extra column compared to the birdlocation table. This collumn tells if a bird is on land or in the water.
#the birds that are not on the mudflats are not taken into account
source("edit_bird_table.R")

##CHECKING THE MODEL
#This script creates 4 dummybirds to check if the model works
source("dummybird.R")
#This script uses a very accurate measuring instrument to check how accurate the model is with predicting
#the presence of water and land on a position.
source("check_accuracy.R")

#this script creates useful craphs from the flow birds table and the ebb birds table
source("creating_graphs.R")








