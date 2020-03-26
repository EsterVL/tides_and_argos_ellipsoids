##editing the time of the checkpoint and give timestamps to checkpoint and tides table 2011
checkpoint$dateTimeOman <- as.POSIXct(checkpoint[, c(1)], format='%d %m %y %H:%M', tz = 'Asia/Dubai')
checkpoint$timestamp <- as.POSIXct(format(checkpoint$dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')
tides_table_2011$timestamp <- paste(tides_table_2011$mm.dd.yyyy, tides_table_2011$hh.mm.ss, sep = ' ')
tides_table_2011$timestamp <- as.POSIXct(strptime(tides_table_2011$time, format='%m.%d.%Y %H:%M', tz = 'UTC'), format='%Y-%m-%d %H:%M:%S')


##The location of the measuring instrument
loc.sp <- SpatialPointsDataFrame(data.frame(loc$X[which(loc$ID == number)], loc$Y[which(loc$ID == number)]), data.frame(loc[which(loc$ID == number), ]))
proj4string(loc.sp)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
flood_value <- as.numeric(extract(Flood_raw,loc.sp[,c(1,2)], cellnumbers=F))
ebb_value <- as.numeric(extract(Ebb_raw,loc.sp[,c(1,2)], cellnumbers=F))

##get a meters to max and tide phase in tides_table 2011
tides_table_2011$meters_to_max <- as.numeric(max(tides_table$z.m.) - tides_table_2011$z.m.)
tides_table_2011$tide_phase<-ifelse(tides_table_2011$z.m. < 0,"flow","ebb")

##merge the checkpoint table and the subsection of the tides table to gather all the data in one table
df <- merge(x=checkpoint, y=tides_table_2011, by="timestamp", all.X=T, sort=F)
df$next_depth <- shift(df[, c(3)], n=1, fill=NA, type="lead")

#find the average meters to max value where the measuring instrument detects zero water height.
zero_vector <- cbind(df$meters_to_max[which(df[, c(3)]!=0.00 & df$next_depth == 0.00)], df$meters_to_max[which(df[, c(3)]==0.00 & df$next_depth != 0.00)])
zero_line <- sum(zero_vector)/length(zero_vector)

#plot the meters to max of df with the zero water height of the measuring instrument and the ebb and flood values of the images.
plot(df[, c(11)] ~ as.POSIXct(x = df$timestamp, format = "%H"), type = 'o', pch = 21, bg = 'orange',
           xlab = 'time', ylab = 'meters to max (m)', main = number)
abline(h=zero_line, col = 'black')
abline(h=ebb_value, col = 'red')
abline(h=abs(flood_value), col = 'blue')

