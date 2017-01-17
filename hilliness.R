if (require(jsonlite) == FALSE) {
  install.packages('jsonlite')
  library(jsonlite)
}

options("scipen"=100)

locations.url <- 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt'
distances.url <- 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/distances_file.txt'
nearby.coordinates.url <- 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/coordinates_file.txt'

locations <- read.table(locations.url, header=TRUE, sep = '\t', quote = '', stringsAsFactors = FALSE)
distances <- read.table(distances.url, header=FALSE, sep = '\t', quote = '', stringsAsFactors = FALSE)
nearby <- read.table(nearby.coordinates.url, header=FALSE, sep = '\t', quote = '', stringsAsFactors = FALSE)

names(distances) <- c('geoid', 'distance.in.km')
names(nearby) <- c('geoid', 'coordinate.string')

google.maps.key <- '' #google maps API key goes here

distances <- distances[distances$distance.in.km <= 321.869,]
merge.file <- merge(distances, nearby)
merge.file <- merge(locations, merge.file, by.x = 'city.id', by.y = 'geoid')

total.list <- data.frame('elevation' = numeric(), 'resolution' = numeric(), 'latitude' = numeric(), 'longitude' = numeric(), 'id' = numeric())
var.data <- data.frame('id' = numeric(), 'sum' = numeric(), 'mean' = numeric(), 'std' = numeric())

for(c in 1:nrow(merge.file)){
  record <- merge.file[c,]
  print(paste(record$city.name, record$state.x))
  id <- record$city.id
  lon <- record$long
  lat <- record$lat
  elev <- record$elevation.x
  coord.string <- record$coordinate.string
  
  google.maps.api <- paste0('https://maps.googleapis.com/maps/api/elevation/json?locations=',coord.string,'&key=',google.maps.key)
  nearby.locs <- fromJSON(google.maps.api)
  nearby.locs <- flatten(nearby.locs$results)
  nearby.locs[17,] <- c(elev, 0, lat, lon)
  nearby.locs$id <- id
  Sys.sleep(.1)
  total.list <- rbind(total.list, nearby.locs)
  
  difference.list <- vector()
  
  
  for(i in 1:nrow(nearby.locs)){
    for(a in 1:nrow(nearby.locs)){
      height <- abs(as.numeric(nearby.locs[i,]$elevation) - as.numeric(nearby.locs[a,]$elevation))
      difference.list[length(difference.list)+1] <- height
    }
  }
  
  difference.list <- difference.list[difference.list != 0]
  t.difference <- sum(difference.list)
  t.mean <- mean(difference.list)
  t.std <- sd(difference.list)
  var.data[nrow(var.data)+1,] <- c(as.integer(id), t.difference, t.mean, t.std)
}


hilliness.data <- merge(locations,var.data, by.x = 'city.id', by.y = 'id')
hilliness.data <- merge(hilliness.data, distances, by.x = 'city.id', by.y = 'geoid')
names(hilliness.data) <- c('id', 'name', 'country', 'long', 'lat', 'state', 'elevation', 'pop', 'sum', 'mean', 'stdv', 'distance.in.km')
hilliness.data$miles <- hilliness.data$distance.in.km * 0.621371

destination.dir <- " " ### destination directory goes here
loc_file <- paste0(destination.dir, "hilliness_information.txt")
write.table(hilliness.data, loc_file, sep = '\t', row.names = FALSE, quote = FALSE)

