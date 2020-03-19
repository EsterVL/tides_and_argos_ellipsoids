#renaming the tables and editing the enviroment collumns to be able to create plots.
ebb <- Ebb_birds_table
flood <- Flow_birds_table
ebb$enviroment <- as.factor(ebb$enviroment)
flood$enviroment <- as.factor(flood$enviroment)

#creating two boxplots 
par(mfrow=c(1,2))
plot(ebb$enviroment, ebb$meters_to_max, ylab="meters to max", xlab = "enviroment", main= "boxplot ebb")
plot(flood$enviroment, flood$meters_to_max, ylab="meters to max", xlab = "enviroment", main= "boxplot flood")

#show the percentages of birds in the water vs on land when the meters to max is devided in 10 categories
mtm_ebb <- cut(ebb$meters_to_max, 10, labels=c(1:10))
mtm_flood <- cut(flood$meters_to_max, 10, labels=c(1:10))
plot(mtm_ebb, ebb$enviroment)
plot(mtm_flood, flood$enviroment)


