# tides_and_argos_allipsoids
this repository the current model

# the steps
## 1. google_earth_engine_Oman
- Change the coordinates of var polygon to the area you need the images from.
- Check if the cloud coverage percentage threshold is giving you good quality images.
- Download the images.
- Walk through the images and delete all the unclear images and all the images with blank areas.

## 2. create_table_datetime.sh
- Run this bash script to create a table with the date and time of all the images.

## 3. Model_bship.R
This script will load all the packages and scrips necessary.
