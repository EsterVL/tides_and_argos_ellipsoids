##Give the tides_table_2011 a timestamp
tides_table_2011$timestamp <- paste(tides_table_2011$mm.dd.yyyy, tides_table_2011$hh.mm.ss, sep = ' ')
tides_table_2011$timestamp <- as.POSIXct(strptime(tides_table_2011$time, format='%m.%d.%Y %H:%M', tz = 'UTC'), format='%Y-%m-%d %H:%M:%S')
##get a meters to max and tide phase in tides_table 2011
tides_table_2011$meters_to_max <- as.numeric(max(tides_table$z.m.) - tides_table_2011$z.m.)
tide_next_point<-shift(tides_table_2011$z.m., n=1, fill=NA, type="lead")
tides_table_2011$tide_phase<-ifelse(tide_next_point > tides_table_2011$z.m.,"flow","ebb")
tides_table_2011<-tides_table_2011[!is.na(tides_table_2011$tide_phase),]
tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']<- -tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']



check_stations <- function(name_station){
  ##Get the table and the number of the station
  checkpoint <- read.csv(name_station)
  number <- as.numeric(gsub("\\D", "", name_station))

  ##editing the time of the checkpoint and give timestamps to checkpoint table
  dateTimeOman <- as.POSIXct(checkpoint[, c(1)], format='%d %m %y %H:%M', tz = 'Asia/Dubai')
  checkpoint$timestamp <- as.POSIXct(format(dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')
  
  ##Give the measuring instrument a location stamp and determine the ebb and flood value
  loc.sp <- SpatialPointsDataFrame(data.frame(loc$X[which(loc$ID == number)], loc$Y[which(loc$ID == number)]), data.frame(loc[which(loc$ID == number), ]))
  proj4string(loc.sp)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  flood_value <- as.numeric(extract(Flood_raw,loc.sp[,c(1,2)], cellnumbers=F))
  ebb_value <- as.numeric(extract(Ebb_raw,loc.sp[,c(1,2)], cellnumbers=F))
  
  ##if model thinks the measuring instrument is in water or on land, return NA, else, check the accuracy.
  if(ebb_value == 99 && flood_value == 99){
    return(NA)
  }
  else if(ebb_value == -99 && flood_value == -99){
    return(NA)
  }
  else{
    ##merge the checkpoint table and the subsection of the tides table to gather all the data in one table
    df <- merge(x=checkpoint, y=tides_table_2011, by="timestamp", all.X=T, sort=F)
    ##Give the df table a checkpoint enviroment collumn. This is based on the waterdepht. 
    ##If waterdepth = 0, enviroment = "land", else it is "water
    df$c_enviroment<-ifelse(df[, c(3)] == 0,"land","water")
    
    ##give the df table a model enviroment collumn. This is based on meters to max
    ##if ebb:
    ##if meters to max > ebb value: water
    ##if meters to max < ebb value: land
    ##if flood:
    ##if meters to max > flood value: land
    ##if meters to max < flood value: water
    df$m_enviroment<-ifelse(df$meters_to_max>ebb_value | df$meters_to_max<flood_value, "land","water")
    
    ##add the next time period to the table and create difference between ebb and flood. 
    difference_enviroment <- df[which(df$c_enviroment != df$m_enviroment), ]
    difference_enviroment$next_time<-shift(difference_enviroment$timestamp, n=1, fill=NA, type="lead")
    difference_enviroment<-difference_enviroment[!is.na(difference_enviroment$next_time),]
    difference_enviroment$label <- difference_enviroment$timestamp-difference_enviroment$next_time
    difference_enviroment$label[difference_enviroment$tide_phase=="flow"] <- -difference_enviroment$label[difference_enviroment$tide_phase=="flow"]
    
    ##Get the time differences of the measuring instrument and the model
    x <- 10
    y <- 10
    ebb_list <- c()
    flood_list <-c()
    for (item in difference_enviroment$label) {
      if(item != 10 && item == abs(item)){
        ebb_list <- c(ebb_list, x)
        x <- 10
      }
      if(item == 10){
        x <- x + 10
      }
      if(item != -10 && item != abs(item)){
        flood_list <- c(flood_list, y)
        y <- 10
      }
      if(item == -10){
        y <- y + 10
      }
    }
    ebb_list <- c(ebb_list, x)
    flood_list <- c(flood_list, y)
    total_list <- c(ebb_list, -flood_list)
    return(total_list)
  }
}

df <- lapply(checkpoints, check_stations)

time_ebb <- c()
time_flood <- c()
for (list in df){
  if(!is.na(list)){
    for(item in list){
      if (item == abs(item)){
        time_ebb <- c(time_ebb, item)
      }
      else{
        time_flood <- c(time_flood, item)
      }
    }
  }
}

par(mfrow=c(1,2))
boxplot(time_ebb, main = "ebb")
boxplot(abs(time_flood), main = "flood")


