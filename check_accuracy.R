#This script is called upon by the script "Model_Bship.R"

##Give the tides_table_2011 a timestamp
tides_table_2011$timestamp <- paste(tides_table_2011$mm.dd.yyyy, tides_table_2011$hh.mm.ss, sep = ' ')
tides_table_2011 <- tides_table_2011[order(tides_table_2011$time),]

tides_table_2011$timestamp <- as.POSIXct(strptime(tides_table_2011$time, format='%m.%d.%Y %H:%M', tz = 'UTC'), format='%Y-%m-%d %H:%M:%S')
##get a meters to max and tide phase in tides_table 2011
tides_table_2011$meters_to_max <- as.numeric(max(tides_table$z.m.) - tides_table_2011$z.m.)
tide_next_point<-shift(tides_table_2011$z.m., n=1, fill=NA, type="lead")
tides_table_2011$tide_phase<-ifelse(tide_next_point > tides_table_2011$z.m.,"flow","ebb")
tides_table_2011<-tides_table_2011[!is.na(tides_table_2011$tide_phase),]
tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']<- -tides_table_2011$meters_to_max[tides_table_2011$tide_phase=='flow']

##empty data.frame in which data will be written  
calData <- data.frame()

##This function loops through the different stations.
for(item in checkpoints){
  ##Get the table and the number of the station
  checkpoint <- read.csv(item)
  number <- as.numeric(gsub("\\D", "", item))
  
  ##delete first and last measurement, this might be false measurement, i.e. 
  ##if gauge was not installed yet
  checkpoint <- checkpoint[-1,]
  checkpoint <- checkpoint[-(nrow(checkpoint)),]
  
  ##editing the time of the checkpoint and give timestamps to checkpoint table
  checkpoint$dateTimeOman <- as.POSIXct(checkpoint[, c(1)], format='%d %m %y %H:%M', tz = 'Asia/Dubai')
  checkpoint$timestamp <- as.POSIXct(format(checkpoint$dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')
  
  ##for some reason the time was different in this file:
  if(number == 509){
    ##editing the time of the checkpoint and give timestamps to checkpoint table
    checkpoint$dateTimeOman <- as.POSIXct(checkpoint[, c(1)], format='%m %d %y %H:%M', tz = 'Asia/Dubai')
    checkpoint$timestamp <- as.POSIXct(format(checkpoint$dateTimeOman,tz="UTC"), format='%Y-%m-%d %H:%M:%S')
  }
  
  ##creating temporary location table to convert to spatialpointsdataframe
  spdf <- loc
  
  ##Give the measuring instrument a location stamp and determine the ebb and flood value
  spdf <- SpatialPointsDataFrame(data.frame(spdf$X[which(spdf$ID == number)], spdf$Y[which(spdf$ID == number)]), data.frame(spdf[which(spdf$ID == number), ]))
  proj4string(spdf)=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  flood_value <- as.numeric(extract(Flood_raw,spdf[,c(1,2)], cellnumbers=F))
  ebb_value <- as.numeric(extract(Ebb_raw,spdf[,c(1,2)], cellnumbers=F))
  
  ##only continue if the position was within the extend of the model
  if (!is.na(ebb_value)){
    ##for some reason I get a positive ebb value at one location, don't know what to do with it, so skip
    if (ebb_value > 0){
      ##set m_environment in the tides table to NA, this will be filled later (but it remembers it because of the loop)
      tides_table_2011$m_enviroment <- NA
      
      ##merge the checkpoint table and the subsection of the tides table to gather all the data in one table
      df <- merge(x=checkpoint, y=tides_table_2011, by="timestamp", all.X=T, sort=F)
      
      ##Give the df table a checkpoint enviroment collumn. This is based on the waterdepth. 
      ##If waterdepth = 0, enviroment = "land", else it is "water
      df$c_enviroment<-ifelse(df[, c(3)] == 0,"land","water")
      
      ##give the df table a model enviroment collumn. This is based on meters to max
      ##if ebb:
      ##if meters to max > ebb value: water
      ##if meters to max < ebb value: land
      ##if flood:
      ##if meters to max > flood value: land
      ##if meters to max < flood value: water
      
      ##identify for each minute if the location at the gauge is in our out of the water according
      ## to the model
      tides_table_2011$m_enviroment <- ifelse(tides_table_2011$meters_to_max>ebb_value | tides_table_2011$meters_to_max<flood_value, "land","water")
      
      ##identify the moment at which there is a change between water and land and vice versa in the gauge data
      changeTimeMeasured <- df$timestamp[which(df$c_enviroment[c(1:(nrow(df)-1))] != df$c_enviroment[c(2:nrow(df))])] + 5*60
      
      ##identify the moment at which there is a change between water and land and vice versa according to the model
      changeTimeModel <- tides_table_2011$timestamp[which(tides_table_2011$m_enviroment[c(1:(nrow(tides_table_2011)-1))] != tides_table_2011$m_enviroment[c(2:nrow(tides_table_2011))])] #+ 0.5*60
      
      ##identify for each measured changepoint when the nearest modelled changepoint is 
      ##empty dataframe that will be filled in a for loop 
      myDiffTime <- data.frame()
      for(j in 1 : length(changeTimeMeasured)){
        myDiffTime <- rbind(myDiffTime,
                            difftime(changeTimeMeasured[j], 
                                     changeTimeModel[which.min(abs(changeTimeModel - changeTimeMeasured[j]))], units = "mins"))
      }
      ##some bookkeeping
      names(myDiffTime) <- 'DiffTime'
      ##ebb or flood
      tidePhase <- df$tide_phase[which(df$c_enviroment[c(1:(nrow(df)-1))] != df$c_enviroment[c(2:nrow(df))])]

      ttt <-data.frame(diffTime = c(myDiffTime),
                       tidePhase = tidePhase,
                       station = number)

      calData <- rbind(calData, ttt)
    }
  }
}

boxplot(as.numeric(calData$DiffTime) ~ calData$tidePhase,
        ylab = 'time difference (mins)',
        xlab = 'tide phase')








