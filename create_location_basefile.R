## Code for creating the US Cities basefile  -- This creates a static file by getting the 
## state, elevation, and population data for from geonames.org.  This file requires a username 
## from geonames.org, which is rate-limited -- hence the creation of a static basefile.

### Downloaded the Cities file from http://bulk.openweathermap.org/sample/
## I found it much easier to download the file than to process it from the internet, since the file itself doesn't change.
## The file is called *city.list.us.json*
file <- '' ## where the openweathermap.org data have been saved
destination.dir <- '' ## destination directory for export files.
username <- ''  ### geonames.org username 

# function for converting meters to miles
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

loc_file <- paste0(destination.dir, "location_information.txt")
write.table(final.data, loc_file, sep = '\t', row.names = FALSE, quote = FALSE)
