##editing the time of the checkpoint and give timestamps to checkpoint and tides table 2011
checkpoint$dateTimeOman <- as.POSIXct(checkpoint$Date.......Time, format='%d %m %y %H:%M', tz = 'Asia/Dubai')
checkpoint$timestamp <- as.POSIXct(format(checkpoint$dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')
tides_table_2011$timestamp <- paste(tides_table_2011$mm.dd.yyyy, tides_table_2011$hh.mm.ss, sep = ' ')
tides_table_2011$timestamp <- as.POSIXct(strptime(tides_table_2011$time, format='%m.%d.%Y %H:%M', tz = 'UTC'), format='%Y-%m-%d %H:%M:%S')


##The location of the measuring instrument
loc.sp <- SpatialPointsDataFrame(data.frame(loc$X[which(loc$ID == 341)], loc$Y[which(loc$ID == 341)]), data.frame(loc[which(loc$ID == 341), ]))
proj4string(loc.sp)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
flood_value <- as.numeric(extract(Flood_raw,loc.sp[,c(1,2)], cellnumbers=F))
ebb_value <- as.numeric(extract(Ebb_raw,loc.sp[,c(1,2)], cellnumbers=F))

##get a meters to max in tides_table 2011
tides_table_2011$meters_to_max <- as.numeric(max(tides_table_2011$z.m.) - tides_table_2011$z.m.)
tides_table_2011$tide_next_point <- shift(tides_table_2011$z.m., n=1, fill=NA, type="lead")
tides_table_2011$tide_phase<-ifelse(tides_table_2011$tide_next_point > tides_table_2011$z.m.,"flow","ebb")
tides_table_2011<-tides_table_2011[!is.na(tides_table_2011$tide_phase),]
tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']<- -tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']


##select the year 2016 and the date times of the tides table that are equal to those of the checkpoint table
tt <- tides_table_2011[tides_table_2011$timestamp >= "2011-12-02 11:39:00" & tides_table_2011$timestamp < "2011-12-03 09:00:00",]

  
##select the hours and minutes of both tables, to be able to properly merge them
tt$tijd <- paste(as.numeric(format(tt$timestamp, '%H')), as.numeric(format(tt$timestamp, '%M')), sep = ':')
checkpoint$tijd <- paste(as.numeric(format(checkpoint$timestamp, '%H')), as.numeric(format(checkpoint$timestamp, '%M')), sep = ':')

##merge the checkpoint table and the subsection of the tides table to gather all the data in one table
df <- merge(x=checkpoint, y=tt, by="tijd", all.X=T, sort=F)

##Get the rows of the tides table that represent the time of the ebb and flood values.
ebb_lijn <- df[which(abs(df$meters_to_max-ebb_value)==min(abs(df$meters_to_max-ebb_value))), ]
vloed_lijn <- df[which(abs(df$meters_to_max-flood_value)==min(abs(df$meters_to_max-flood_value))), ]

##plot the waterhight from the measuring instrument over time
plot(checkpoint$Depth341 ~ as.POSIXct(x = checkpoint$timestamp, format = "%H"), type = 'o', pch = 21, bg = 'orange',
     xlab = 'time', ylab = 'water depth (m)', main = '2011')

abline(v=ebb_lijn$timestamp.x, col = 'red')
abline(v=vloed_lijn$timestamp.x, col = 'blue')

# timedifference between model and measuring instrument for ebb
# model -> 12:39:00
# meetinstrument -> 14:49:00
# 
# timedifference between model and measuring instrument for flood
# model -> 19:19:00
# meetinstrument -> 20:49:00





