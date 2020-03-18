##input files
library(lubridate)
Flood_raw<-brick('Flood_raw_Oman.grd')
source("edit_tables.R")
Ebb_raw<-brick('Ebb_raw_Oman.grd')
checkpoint <- read.csv("Stat341.csv")
loc <- read.csv("station_field_data.csv")

##editing the time of the checkpoint
checkpoint$dateTimeOman <- as.POSIXct(checkpoint$Date.......Time, format='%d %m %y %H:%M', tz = 'Asia/Dubai')
checkpoint$timestamp <- as.POSIXct(format(checkpoint$dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')

##The location of the measuring instrument
loc <- loc[which(loc$ID == 341), ]
loc.sp <- SpatialPointsDataFrame(data.frame(loc$X, loc$Y), data.frame(loc))
proj4string(loc.sp)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
flood_value <- as.numeric(extract(Flood_raw,loc.sp[,c(1,2)], cellnumbers=F))
ebb_value <- as.numeric(extract(Ebb_raw,loc.sp[,c(1,2)], cellnumbers=F))

##get a meters to max in tides_table
tides_table$meters_to_max <- as.numeric(max(tides_table$z.m.) - tides_table$z.m.)
tides_table$tide_phase<-ifelse(tides_table$tide_next_point > tides_table$z.m.,"flow","ebb")
tides_table<-tides_table[!is.na(tides_table$tide_phase),]
tides_table$meters_to_max[tides_table$tide_phase=='flow']<- -tides_table$meters_to_max[tides_table$tide_phase=='flow']


##select the year 2016 and the date times of the tides table that are equal to those of the checkpoint table
par(mfrow=c(2,2))
tt <- tides_table[tides_table$timestamp >= "2016-12-02 11:39:00" & tides_table$timestamp < "2016-12-03 22:59:00",]
tt <- tides_table[tides_table$timestamp >= "2017-12-02 11:39:00" & tides_table$timestamp < "2017-12-03 22:59:00",]
tt <- tides_table[tides_table$timestamp >= "2018-12-02 11:39:00" & tides_table$timestamp < "2018-12-03 22:59:00",]
tt <- tides_table[tides_table$timestamp >= "2019-12-02 11:39:00" & tides_table$timestamp < "2019-12-03 22:59:00",]


##select the hours and minutes of both tables, to be able to properly merge them
tt$tijd <- paste(as.numeric(format(tt$timestamp, '%H')), as.numeric(format(tt$timestamp, '%M')), sep = ':')
checkpoint$tijd <- paste(as.numeric(format(checkpoint$timestamp, '%H')), as.numeric(format(checkpoint$timestamp, '%M')), sep = ':')

##merge the checkpoint table and the subsection of the tides table to gather all the data in one table
df <- merge(x=checkpoint, y=tt, by="tijd", all=F, sort=F)

##Get the rows of the tides table that represent the time of the ebb and flood values.
df_ebb <- df[which.min(abs(df$meters_to_max-ebb_value)), ]
df_flood <- df[which.min(abs(df$meters_to_max-flood_value)), ]

##plot the waterhight from the measuring instrument over time
plot(checkpoint$Depth341 ~ checkpoint$timestamp, type = 'o', pch = 21, bg = 'orange',
     xlab = 'time', ylab = 'water depth (m)', main = '2019')
abline(v=df_ebb$timestamp.x, col = 'red')
abline(v=df_flood$timestamp.x, col = 'blue')









