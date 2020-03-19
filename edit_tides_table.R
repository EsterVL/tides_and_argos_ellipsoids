##this script edits tides_table so all the usefull information will available.
##the script will return the tides table with the columns: 
##lat, lon, timestamp, z.m., tide_phase and meters_to_max

#the mm-dd-yyyy and the hh-mm-ss columns are combined here
tides_table$timestamp <- paste(tides_table$mm.dd.yyyy, tides_table$hh.mm.ss, sep = ' ')

#the tide_next_point is calculated to determine the tide phase later
tides_table$tide_next_point<-shift(tides_table$z.m., n=1, fill=NA, type="lead")

#The tide_phase is determined by the tide_next_point
tides_table$tide_phase<-ifelse(tides_table$tide_next_point > tides_table$z.m.,"flow","ebb")

#The meters to max is determined and the values that correspond with flow will be made negative
tides_table$meters_to_max <- max(tides_table$z.m.)-tides_table$z.m.
tides_table<-tides_table[!is.na(tides_table$tide_phase),]
tides_table$meters_to_max[tides_table$tide_phase=='flow']<- -tides_table$meters_to_max[tides_table$tide_phase=='flow']

#remove all the unnecessary collumns
tides_table <- tides_table[order(tides_table$timestamp),]
tides_table <- tides_table[, c("timestamp", "z.m.", "tide_phase", "meters_to_max", "Lat", "Lon")]

