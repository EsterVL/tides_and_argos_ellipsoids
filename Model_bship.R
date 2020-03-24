##This script calls uppon all the different scripts and imports 
##all the tables that are needed forthe model

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
metadata_images_table <- read.csv("tables/datetime_table.txt", sep="")
metadata_tiff_table <- list.files(path = "tiff_images", pattern='local_tidal_level_*', full.names=TRUE)
checkpoint <- read.csv("tables/Stat341.csv")
loc <- read.csv("tables/station_field_data.csv")
tides_table_2011 <- read.csv("tables/oman_tides_2011.txt", sep = "")

#This script edits tides_table in a way that all the useful information is available
source("edit_tides_table.R")

#This script gives all the tables a propper location- and timestamp
source("add_stamps.R")

#This script adds all the tide information from the tides table, to the birdlocation and the metadata images tables
source("merge_tables.R")

#This script creates two brickfiles from all the tiff images. One brickfile is for ebb and one is for flood.
source("create_brickfiles.R")
#if brickfiles already exist, use this code to save time:
# Flood_raw<-brick('Flood_raw_Oman.grd')
# Ebb_raw<-brick('Ebb_raw_Oman.grd')

#This script creates two new tables. One table with the information about the birds that are present during ebb
#and one table with the information about the birds that are present during flood. Both tables also have an
#extra column compared to the birdlocation table. This collumn tells if a bird is on land or in the water.
source("edit_bird_table.R")

##CHECKING THE MODEL
#This script creates 4 dummybirds to check if the model works
#source("dummybird.R")
#This script uses a very accurate measuring instrument to check how accurate the model is with predicting
#the presence of water and land on a position.
#source("check_accuracy.R")

#this script creates useful craphs from the flow birds table and the ebb birds table
source("creating_graphs.R")








