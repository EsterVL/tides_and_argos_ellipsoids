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

## 3. Merge_ndwi_tide_prediction.R
(This script uses the cross_gam_function_ER.R, the split_raster.R and the edit_tables.R scripts)
- Make sure the path to all the files in all the scripts are correct.
- Set your working directory correctly.
- Run this script to create two brickfiles -> one for Ebb and one for Flow.

## 4. bird_data.R
- Run this script to determine if a bird is in the water or on land.
