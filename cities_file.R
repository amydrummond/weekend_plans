## Code for creating the US Cities basefile  -- This creates a static file by getting the 
## state, elevation, and population data for from geonames.org.  This file requires a username 
## from geonames.org, which is rate-limited -- hence the creation of a static basefile.

### Downloaded the Cities file from http://bulk.openweathermap.org/sample/
file <- '<<LOCATION OF UNZIPPED CITIES FILE -- will be named city.list.us.json'
destination.dir <- "<<LOCATION OF OUTPUT FILE"
username <- '<<USERNAME FOR geonames.org>>' 


meters.to.miles <- function(number){
  miles <- number * 0.000621371
  return(miles)
}

if (require(geosphere) == FALSE) {
  install.packages('geosphere')
  library(geosphere)
}

if (require(dplyr) == FALSE) {
  install.packages('dplyr')
  library(dplyr)
}

if (require(jsonlite) == FALSE) {
  install.packages('jsonlite')
  library(jsonlite)
}

if (require(stringr) == FALSE) {
  install.packages('stringr')
  library(stringr)
}

if (require(XML) == FALSE) {
  install.packages('XML')
  library(XML)
}

data <- read.table(file, sep = ',', quote = '\"', stringsAsFactors = FALSE)
data$V1 <- substring(data$V1,6)
data$V2 <- substring(data$V2,6)
data$V4 <- as.numeric(substring(data$V4,12))
data$V5 <- substring(data$V5,5)
data$V5 <- as.numeric(gsub("}}", "", data$V5))
names(data) <- c('city.id', 'city.name', 'country', 'long', 'lat')

#row = 1
data$state <- 'none'
data$elevation <- 'none'
data$population <- 'none'

while(row<nrow(data)){
  print(row)
  print(data[row,2])
  geoid <- data[row,1]
  api.get <- paste('http://api.geonames.org/get?geonameId=',geoid,'&username=',username,sep = '')
  parsed <- (xmlTreeParse(api.get))
  xmltop = xmlRoot(parsed)
  details <- xmlSApply(xmltop, function(x) xmlSApply(x, xmlValue))
  details_df <- data.frame(t(details),row.names=NULL)
  state.name <- (details_df$adminName1[[1]])
  elevation <- details_df$elevation[[1]]
  population <- details_df$population[[1]]
  if(length(state.name)>0)data$state[row] <- state.name
  if(length(elevation)>0)data$elevation[row] <- elevation
  if(length(population)>0){data$population[row] <- population}
  Sys.sleep(2)
  row = row+1
}

### Hilliness -- first attempt --


data <- data[order(data$dist),]

data.attempt <- data
data.attempt$dist_1 <- 0
data.attempt$elev_1 <- 0
data.attempt$dist_2 <- 0
data.attempt$elev_2 <- 0
data.attempt$dist_3 <- 0
data.attempt$elev_3 <- 0
data.attempt$dist_4 <- 0
data.attempt$elev_4 <- 0
data.attempt$dist_5 <- 0
data.attempt$elev_5 <- 0
data.attempt$dist_6 <- 0
data.attempt$elev_6 <- 0
data.attempt$dist_7 <- 0
data.attempt$elev_7 <- 0
data.attempt$dist_8 <- 0
data.attempt$elev_8 <- 0
data.attempt$dist_9 <- 0
data.attempt$elev_9 <- 0
data.attempt$dist_10 <- 0
data.attempt$elev_10 <- 0
data.attempt$dist_11 <- 0
data.attempt$elev_11 <- 0
data.attempt$dist_12 <- 0
data.attempt$elev_12 <- 0

print("Now calculating nearest neighbors, their distances, and elevations.")
row = 1
while(nrow(data.attempt)){
  print(row)
  home.coord <- c(data.attempt$long[row], data.attempt$lat[row])
  if((row-6)>0){
    away.coord <- c(data.attempt$long[row-6], data.attempt$lat[row-6])
    data.attempt$dist_1[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_1[row] <- data.attempt$elevation[row-6]
  }
  if((row-5)>0){
    away.coord <- c(data.attempt$long[row-5], data.attempt$lat[row-5])
    data.attempt$dist_2[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_2[row] <- data.attempt$elevation[row-5]
  }
  if((row-4)>0){
    away.coord <- c(data.attempt$long[row-4], data.attempt$lat[row-4])
    data.attempt$dist_3[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_3[row] <- data.attempt$elevation[row-4]
  } 
  if((row-3)>0){
    away.coord <- c(data.attempt$long[row-3], data.attempt$lat[row-3])
    data.attempt$dist_4[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_4[row] <- data.attempt$elevation[row-3]
  }
  if((row-2)>0){
    away.coord <- c(data.attempt$long[row-2], data.attempt$lat[row-2])
    data.attempt$dist_5[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_5[row] <- data.attempt$elevation[row-2]
  }
  if((row-1)>0){
    away.coord <- c(data.attempt$long[row-1], data.attempt$lat[row-1])
    data.attempt$dist_6[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_6[row] <- data.attempt$elevation[row-1]
  } 
  if((row+1)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+1], data.attempt$lat[row+1])
    data.attempt$dist_7[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_7[row] <- data.attempt$elevation[row+1]
  }
  if((row+2)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+2], data.attempt$lat[row+2])
    data.attempt$dist_8[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_8[row] <- data.attempt$elevation[row+2]
  }
  if((row+3)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+3], data.attempt$lat[row+3])
    data.attempt$dist_9[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_9[row] <- data.attempt$elevation[row+3]
  }
  if((row+4)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+4], data.attempt$lat[row+4])
    data.attempt$dist_10[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_10[row] <- data.attempt$elevation[row+4]
  }
  if((row+5)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+5], data.attempt$lat[row+5])
    data.attempt$dist_11[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_11[row] <- data.attempt$elevation[row+5]
  }
  if((row+6)<nrow(data.attempt)){
    away.coord <- c(data.attempt$long[row+6], data.attempt$lat[row+6])
    data.attempt$dist_12[row] <- meters.to.miles(distHaversine(home.coord, away.coord))
    data.attempt$elev_12[row] <- data.attempt$elevation[row+6]
  }
  row <- row+1
}

print("Now calculating elevation changiness.")
row = 1
data.attempt$ave.close <- 0
data.attempt$std.close <- 0
while(nrow(data.attempt)){
  distances <- c(data.attempt$dist_1[row], data.attempt$dist_2[row], data.attempt$dist_3[row],
                 data.attempt$dist_4[row], data.attempt$dist_5[row], data.attempt$dist_6[row], 
                 data.attempt$dist_7[row], data.attempt$dist_8[row], data.attempt$dist_9[row],
                 data.attempt$dist_10[row], data.attempt$dist_11[row], data.attempt$dist_12[row])
  sorted <- sort(distances)
  sorted <- sorted[sorted > 0]
  close_1 <- sorted[1]
  el.name_1 <- paste('elev_', grep(close_1,distances), sep = '')
  el.1.loc <- grep(el.name_1, names(data.attempt))[1]
  el.1 <- data.attempt[row,][[el.1.loc]]
  dif.1 <- abs(as.numeric(data.attempt$elevation[row])-as.numeric(el.1))
  gain.1 <- dif.1/close_1
  close_2 <- sorted[2]
  el.name_2 <- paste('elev_', grep(close_2,distances), sep = '')
  el.2.loc <- grep(el.name_2, names(data.attempt))[1]
  el.2 <- data.attempt[row,][[el.2.loc]]
  dif.2 <- abs(as.numeric(data.attempt$elevation[row])-as.numeric(el.2))  
  gain.2 <- dif.2/close_2
  close_3 <- sorted[3]
  el.name_3 <- paste('elev_', grep(close_3,distances), sep = '')
  el.3.loc <- grep(el.name_3, names(data.attempt))[1]
  el.3 <- data.attempt[row,][[el.3.loc]]
  dif.3 <- abs(as.numeric(data.attempt$elevation[row])-as.numeric(el.3))
  gain.3 <- dif.3/close_3
  close_4 <- sorted[4]
  el.name_4 <- paste('elev_', grep(close_4,distances), sep = '')
  el.4.loc <- grep(el.name_4, names(data.attempt))[1]
  el.4 <- data.attempt[row,][[el.4.loc]]
  dif.4 <- abs(as.numeric(data.attempt$elevation[row])-as.numeric(el.4))
  gain.4 <- dif.4/close_4
  close_5 <- sorted[5]
  el.name_5 <- paste('elev_', grep(close_5,distances), sep = '')
  el.5.loc <- grep(el.name_5, names(data.attempt))[1]
  el.5 <- data.attempt[row,][[el.5.loc]]
  dif.5 <- abs(as.numeric(data.attempt$elevation[row])-as.numeric(el.5))  
  gain.5 <- dif.5/close_5
  gains <- c(gain.1, gain.2, gain.3, gain.4, gain.5)
  data.attempt$ave.close[row] <- mean(gains)
  data.attempt$std.close[row] <- sd(gains)
  row <- row + 1
}

data.attempt <-  data.attempt[order((data.attempt$std.close), decreasing = TRUE),]

data.attempt$changiness <-  as.numeric(cut2(data.attempt$ave.close, g = 10))
  
