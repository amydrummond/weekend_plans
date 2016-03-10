###This includes everything to pull limited data based on proximity and weather.

file <- '<<LOCATION OF JSON CITIES FILE>>'
destination.dir <- "<<DESTINATION FILE DIRECTORY>>"
key <- '<<API KEY FOR openweathermap.org>>'
username <- '<<USERNAME FOR geonames.org>>'
home <- c(-77.070731, 38.807483)
ideal.temp <- 72

meters.to.miles <- function(number){
  miles <- number * 0.000621371
  return(miles)
}

if (require(jsonlite) == FALSE) {
  install.packages('jsonlite')
  library(jsonlite)
}


if (require(stringr) == FALSE) {
  install.packages('stringr')
  library(stringr)
}

if (require(geosphere) == FALSE) {
  install.packages('geosphere')
  library(geosphere)
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
north.most <- 40.7142700
east.most <- -74.0059700
south.most <- 36.6220287
west.most <- -83.5551893
locations <- data[data$city.id < 10,]

print('Now calculating the regional cities.')
row = 1
while(row<nrow(data)){
  item = data[row,]
  if(item[5]<north.most&&item[5]>south.most&&item[4]<east.most&&item[4]>west.most){
  locations <- rbind(locations, item)
  }
  row = row +1
}

print('Now calculating the distances to regional cities.')

locations$dist <- 0 
row = 1
while(row<nrow(locations)){
  item = locations[row,]
  long <- item[4]
  long <- long[1,]
  lat <- item[5]
  lat <- lat[1,]
  coord <- c(long,lat)
  dist <- distHaversine(home, coord)
  miles.dist <- meters.to.miles(dist)
  locations$dist[row]<-miles.dist
  row = row +1
}

print('Now finding states and elevations for the cities.')

locations.short <- locations
locations.short$state <- 'none'
row = 1
while(row<nrow(locations.short)){
  print(row)
  print(locations.short[row,2])
  geoid <- locations.short[row,1]
  api.get <- paste('http://api.geonames.org/get?geonameId=',geoid,'&username=',username,sep = '')
  parsed <- (xmlTreeParse(api.get))
  xmltop = xmlRoot(parsed)
  details <- xmlSApply(xmltop, function(x) xmlSApply(x, xmlValue))
  details_df <- data.frame(t(details),row.names=NULL)
  state.name <- (details_df$adminName1[[1]])
  elevation <- details_df$elevation[[1]]
  population <- details_df$population[[1]]
  locations.short$state[row] <- state.name
  Sys.sleep(2)
  row = row+1
}
print('Now getting local weather.'
final.locations <- merge(locations,locations.short, all.x = TRUE)
geoid = 4744106
weather.api <- paste('http://api.openweathermap.org/data/2.5/forecast/city?id=', geoid, '&APPID=', key, sep='')
weather <- fromJSON(weather.api)[5]
weather <- weather[1][[1]]
weather$id <- geoid
weather <- flatten(weather)

print('Now getting regional weather.')
row = 1
while(row<nrow(locations)){
  print(row)
  geoid <- locations[row,1]
  weather.api <- paste('http://api.openweathermap.org/data/2.5/forecast/city?id=', geoid, '&APPID=', key, sep='')
  this.weather <- fromJSON(weather.api)[5]
  this.weather <- this.weather[1][[1]]
  print(head(this.weather))
  this.weather$id <- geoid
  this.weather <- flatten(this.weather)
  weather <- rbind(weather, this.weather)
  Sys.sleep(2)
  row = row+1
}

