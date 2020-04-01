#This script is called upon by the script "Model_Bship.R"

#renaming the tables and editing the enviroment collumns to be able to create plots.
ebb <- Ebb_birds_table
flood <- Flow_birds_table
ebb$enviroment <- as.factor(ebb$enviroment)
flood$enviroment <- as.factor(flood$enviroment)



#creating two boxplots that show the distribution of birds along the waterline
par(mfrow=c(1,2))
e_to_waterline <- Ebb_birds_table$tiff_value - Ebb_birds_table$meters_to_max
boxplot(e_to_waterline, ylab="water height (in meters)", xlab = "birds", main= "Ebb")
abline(h=0, col="blue")

f_to_waterline <- abs(Flow_birds_table$tiff_value) - abs(Flow_birds_table$meters_to_max)
boxplot(f_to_waterline, ylab="water height (in meters)", xlab = "birds", main= "Flood")
abline(h=0, col="blue")


#show the number of birds on land and in the water for ebb and flood
plot(ebb$enviroment, ylab="number of birds", main= "Ebb")
plot(flood$enviroment, ylab="number of birds", main= "Flood")



