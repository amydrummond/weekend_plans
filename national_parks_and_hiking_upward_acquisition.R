## This gets data from Wikipedia about National Monuments, National Parks, and World Heritage Sites in the US. 
## It also captures Hiking Upward hikes.

if (require(rvest) == FALSE) {
  install.packages('rvest')
  library(rvest)
}

if (require(XML) == FALSE) {
  install.packages('XML')
  library(XML)
}

if (require(reshape2) == FALSE) {
  install.packages('reshape2')
  library(reshape2)
}


if (require(Hmisc) == FALSE) {
  install.packages('Hmisc')
  library(Hmisc)
}

if (require(geosphere) == FALSE) {
  install.packages('geosphere')
  library(geosphere)
}

if (require(jsonlite) == FALSE) {
  install.packages('jsonlite')
  library(jsonlite)
}

### This code-snippet allows me to use code that I stored in github that I haven't packaged yet. 

source_https <- function(u, unlink.tmp.certs = FALSE) {
  # load package
  if (require(RCurl) == FALSE) {
    install.packages('RCurl')
    library(RCurl)
  }
  
  # read script lines from website using a security certificate
  if(!file.exists("cacert.pem")) download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile = "cacert.pem")
  script <- getURL(u, followlocation = TRUE, cainfo = "cacert.pem")
  if(unlink.tmp.certs) unlink("cacert.pem")
  
  # parase lines and evealuate in the global environement
  eval(parse(text = script), envir= .GlobalEnv)
}

## In this case, the code is a bunch of 

source_https("https://raw.githubusercontent.com/amydrummond/scrape_functions/master/html_scrape_functions.R")

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

## Get national monuments

monuments.url <- "https://en.wikipedia.org/wiki/List_of_National_Monuments_of_the_United_States"
monuments <- monuments.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[3]') %>%
  html_table()
monuments <- monuments[[1]]
monuments <- transform(monuments, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
monuments <- transform(monuments, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
monuments <- transform(monuments, coordinates = colsplit(location.decimal, pattern = "Ã¯Â»Â¿ ", c("decimal", "name")))
monuments <- transform(monuments, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

monuments <- data.frame('name' = monuments$National.Monument.Name, 'state' = monuments$state.state, 
                        'latitude' = monuments$coord.latitude, 'longitude' = monuments$coord.longitude, 'description' = monuments$Description)

## Add an ID
monuments$id.number <- seq(100:228)
monuments$id <- paste0("NM_", monuments$id.number)

## Transform -- pull out state and latitude
monuments$update.state <- ''

for(i in 1:nrow(monuments)){
  monuments$update.state[i] <- substring(monuments$state[i], 1,(regexpr("([0-9]+).*$", monuments$state[i])-1))
  print (substring(monuments$state[i], 1,(regexpr("([0-9]+).*$", monuments$state[i])-1)))
}

monuments$update.longitude <- ''
for(i in 1:nrow(monuments)){
  monuments$update.longitude[i] <- substring(monuments$longitude[i], 1,(regexpr(" ", monuments$longitude[i])-1))
  print(substring(monuments$longitude[i], 1,(regexpr(" ", monuments$longitude[i])-1)))
}

## create a dictionary-type list to add to JSON
mon.list <- list()
for(i in 1:nrow(monuments)){
  mon.list.item <- list("city" = '', "state" = monuments$update.state[i], "country" = 'US', "activities" = "hiking", 
           "lon" = monuments$update.longitude[i],  "lat" = monuments$latitude[i], "name" = monuments$name[i], "parent_id" = '', 
           "date_created" = '', "directions" = '', 'children' = '', "unique_id"= monuments$id[i], "description" = as.character(monuments$description[i]))
  key <- monuments$id[i]
  mon.list[[key]] <- mon.list.item
}


## Acquire parks

parks.url <- "https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States"
parks <- parks.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%
  html_table()
parks <- parks[[1]]
parks <- transform(parks, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
parks <- transform(parks, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
parks <- transform(parks, coordinates = colsplit(location.decimal, pattern = "Ã¯Â»Â¿ ", c("decimal", "name")))
parks <- transform(parks, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

parks <- data.frame('name' = parks$Name, 'state' = parks$state.state, 
                    'latitude' = parks$coord.latitude, 'longitude' = parks$coord.longitude, 'description' = parks$Description)

## Add an ID
parks$id.number <- seq(500:558)
parks$id <- paste0("NP_", parks$id.number)

## Transform -- pull out state and latitude
parks$update.state <- ''

for(i in 1:nrow(parks)){
  parks$update.state[i] <- substring(parks$state[i], 1,(regexpr("([0-9]+).*$", parks$state[i])-1))
  print (substring(parks$state[i], 1,(regexpr("([0-9]+).*$", parks$state[i])-1)))
}

parks$update.longitude <- ''
for(i in 1:nrow(parks)){
  parks$update.longitude[i] <- substring(parks$longitude[i], 1,(regexpr(" ", parks$longitude[i])-1))
  print(substring(parks$longitude[i], 1,(regexpr(" ", parks$longitude[i])-1)))
}

## create a dictionary-type list to add to JSON
parks.list <- list()
for(i in 1:nrow(parks)){
  parks.list.item <- list('', parks$update.state[i], 'US', "hiking", 
                     parks$update.longitude[i], parks$latitude[i], parks$name[i], parent_id = '', 
                     '', '', '', parks$id[i], as.character(parks$description[i]))
  names(parks.list.item) <- c('city', 'state', 'country', 'activities', 'lon', 'lat', 'name', 'parent_id', 'date_created',
                              'directions', 'children', 'unique_id', 'description')
  key <- parks$id[i]
  parks.list[[key]] <- parks.list.item
}

## Acquire world heritage sites in America

heritage.url <- "https://en.wikipedia.org/wiki/List_of_World_Heritage_Sites_in_the_Americas"
heritage <- heritage.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%
  html_table()
heritage <- heritage[[1]]
heritage <- transform(heritage, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
heritage <- transform(heritage, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
heritage <- transform(heritage, coordinates = colsplit(location.decimal, pattern = "Ã¯Â»Â¿ ", c("decimal", "name")))
heritage <- transform(heritage, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

heritage <- data.frame('name' = heritage$Site, 'state' = heritage$state.state, 
                       'latitude' = heritage$coord.latitude, 'longitude' = heritage$coord.longitude, 'description' = heritage$Description)

heritage.usa <- heritage[substring(heritage$state, 1, 13)== 'United States',]
heritage.usa$state <- substring(heritage.usa$state,14)
heritage.usa$state <- substring(heritage.usa$state, 1, nchar(heritage.usa$state)-1)

## Add an ID
heritage.usa$id.number <- seq(800:818)
heritage.usa$id <- paste0("UN_", heritage.usa$id.number)

## Transform -- pull out state and latitude
heritage.usa$update.state <- ''

for(i in 1:nrow(heritage.usa)){
  heritage.usa$update.state[i] <- substring(heritage.usa$state[i], 1,(regexpr("([0-9]+).*$", heritage.usa$state[i])-1))
  print (substring(heritage.usa$state[i], 1,(regexpr("([0-9]+).*$", heritage.usa$state[i])-1)))
}

heritage.usa$update.longitude <- ''
for(i in 1:nrow(heritage.usa)){
  heritage.usa$update.longitude[i] <- substring(heritage.usa$longitude[i], 1,(regexpr(" ", heritage.usa$longitude[i])-1))
  print(substring(heritage.usa$longitude[i], 1,(regexpr(" ", heritage.usa$longitude[i])-1)))
}

## create a dictionary-type list to add to JSON
heritage.list <- list()
for(i in 1:nrow(heritage.usa)){
  heritage.list.item <- list('', heritage.usa$update.state[i], 'US', "hiking", 
                          heritage.usa$update.longitude[i], heritage.usa$latitude[i], heritage.usa$name[i], parent_id = '', 
                          '', '', '', heritage.usa$id[i], as.character(heritage.usa$description[i]))
  names(heritage.list.item) <- c('city', 'state', 'country', 'activities', 'lon', 'lat', 'name', 'parent_id', 'date_created',
                              'directions', 'children', 'unique_id', 'description')
  key <- heritage.usa$id[i]
  heritage.list[[key]] <- heritage.list.item
}


hikingupward.url <- 'http://www.hikingupward.com/maps/'
hikingupward.text <- readLines(hikingupward.url)
startline <- 1
start <- 0
while(startline < length(hikingupward.text)){
  test <- hikingupward.text[startline]
  if(grepl('createHikes()',test)){
    start <- startline
    startline <- length(hikingupward.text)
  }
  startline = startline+1
}

snip.start <- hikingupward.text[start:length(hikingupward.text)]
startline <- 1
end <- 0
while(startline < length(snip.start)){
  test <- snip.start[startline]
  if(grepl("\\t\\t\\t}",test)){
    end <- startline
    startline <- length(snip.start)
  }
  startline = startline+1
}

hikes <- snip.start[1:end]
finish <- length(hikes)
finish = finish - 1
hikes <- hikes[2:finish]
hike.frame <- as.data.frame(hikes)
hike.frame$hikes <- substring(hike.frame$hikes, 24)
hike.frame <- transform(hike.frame, hikes = colsplit(hikes, pattern = ",", c("name", "latitude", "longitude", "url", "length", "difficulty", "streams", "views", "gain", "solitude", "camping") ))
hike.frame <- hike.frame$hikes
hike.frame$name <- gsub('"', '', hike.frame$name)
hike.frame$latitude <- gsub('new google.maps.LatLng\\(', '', hike.frame$latitude)
hike.frame$longitude <- gsub('\\)', '', hike.frame$longitude)
hike.frame$url <- gsub('"', '', hike.frame$url)
hike.frame$length <- gsub('"', '', hike.frame$length)
hike.frame$difficulty <- gsub('"', '', hike.frame$difficulty)
hike.frame$streams <- gsub('"', '', hike.frame$streams)
hike.frame$views <- gsub('"', '', hike.frame$views)
hike.frame$gain <- gsub('"', '', hike.frame$gain)
hike.frame$solitude <- gsub('"', '', hike.frame$solitude)
hike.frame$camping <- gsub('"', '', hike.frame$camping)
hike.frame$camping <- gsub('\\)\\);', '', hike.frame$camping)
hike.frame$gain.per.mile <- as.numeric(hike.frame$gain)/as.numeric(hike.frame$length)
hike.frame$steepness <-  as.numeric(cut2(hike.frame$gain.per.mile, g = 5))
hike.frame$url <- trim(hike.frame$url)
hike.frame <- hike.frame[substr(hike.frame$url, 1, 4)=='http',]

## Get city, state, country, activity, parent_id, date_created, directions, children, unique_id, description

## Add an ID
hike.frame$id.number <- seq(1:nrow(hike.frame))
hike.frame$id <- paste0("HU_", hike.frame$id.number)

hike.frame$city <- ''
hike.frame$state <- ''
hike.frame$country <- 'US'
hike.frame$activity <- 'hiking'
hike.frame$parent_id <- ''
hike.frame$date_created <- ''
hike.frame$directions <- ''
hike.frame$children <- ''
hike.frame$desciption <- ''

hike.frame <- hike.frame[-1,]

### Some scraping
for(i in 1:nrow(hike.frame)){
  url <- hike.frame$url[i]
  print(hike.frame$name[i])
  page <- readLines(trim(url))
  desc.lines <- grep('name="description"', page)[1]
  city.state.lines <- grep("CityName=", page)
  if(length(city.state.lines)<1){city.state.lines <- grep("forecast.weather.gov", page)}
  desc <- string.clip(page[desc.lines], 'content=\"', '\">')
  if(length(desc)==0){desc <- ''}
  
  if(length(grep("Get Directions", page))>0){
    parking.lot <-page.clip(page, "Get Directions", "</form>")
    if(length(grep("</span>",parking.lot))>0){
      parking.line <- parking.lot[grep("</span>",parking.lot)[1]]
      if((regexpr("</div>", parking.line))[1]>0){
        parking.string <- string.clip(parking.line, "</span>", "</div>")
        ref.rem <- string.clip(parking.string, "<", ">")
        if(nchar(ref.rem)>0){
          parking.string <- str_replace(parking.string, ref.rem, '')}
        parking.string <- str_replace(parking.string, '<>', '')
        directions <- str_replace(parking.string, '</a>', '')
        print(directions)
      } else {directions <- ''}
    } else {directions <- ''}
  } else {directions <- ''}
  
  
  if(length(grep('CityName=', page))>0){
    city <- string.clip(page[city.state.lines], 'CityName=', '&')
  } else {
    line <- string.clip(page[city.state.lines], '<a href="', '</a>')
    city <- string.clip(line, '>', ' Weather Forecast')
  }
  
  if(length(grep('CityName=', page))>0){
    state <- string.clip(page[city.state.lines], '&state=', '&')
  } else if(regexpr(',', city)[1]>0){
    state <- trim(substring(city, regexpr(',', city)+1))
    city <- trim(substring(city, 1, regexpr(',', city)-1))
  }
  
  hike.frame$city[i] <- city
  hike.frame$state[i] <- state
  hike.frame$directions[i] <- directions
  hike.frame$desciption[i] <- desc
  print(paste0("Done with ", hike.frame$name[i]))
  Sys.sleep(.1)
}

upward.list <- list()
for(i in 1:nrow(hike.frame)){
  upward.list.item <- list(trim(hike.frame$city[i]), trim(hike.frame$state[i]), 'US', "hiking", 
                                trim(hike.frame$longitude[i]), trim(hike.frame$latitude[i]), trim(hike.frame$name[i]), 
                           parent_id = '',  '', '', '', trim(hike.frame$id[i]), as.character(hike.frame$description[i]))
  names(upward.list.item) <- c('city', 'state', 'country', 'activities', 'lon', 'lat', 'name', 'parent_id', 'date_created',
                                 'directions', 'children', 'unique_id', 'description')
  key <- trim(hike.frame$id[i])
  upward.list[[key]] <- upward.list.item
}

additions <- c(mon.list, parks.list, upward.list, heritage.list)

### Bring in location and distance information.

loc.url <- 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt'
locations <- read.table(loc.url, header = TRUE, sep = '\t', stringsAsFactors = FALSE)

distances.url <- 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/distances_file.txt'
distances <- read.table(distances.url, header = FALSE, sep = '\t', stringsAsFactors = FALSE)
distances <- distances[distances$V2 <= 321.869,]
locations <- merge(locations, distances, by.x = 'city.id', by.y = 'V1')

city.hikes <- list()

for(loc in 1:nrow(locations)){
  print(locations$city.name[loc])
  hikes.avail <- vector()
  id <- as.character(locations$city.id[loc])
  loc.long <- locations$long[loc]
  loc.lat <- locations$lat[loc]
  loc.coord <- c(loc.long,loc.lat)
  for(added in additions){
    added.id <- added$unique_id
    added.long <- added$lon
    if(is.na(suppressWarnings( as.numeric(added.long)))){
      added.long <- substring(added.long, 1, nchar(added.long)-1)
      added.long <- as.numeric(added.long)
    } else {added.long <- as.numeric(added.long)}
    added.lat <- added$lat
    if(is.na(suppressWarnings( as.numeric(added.lat)))){
      added.lat <- substring(added.lat, 1, nchar(added.lat)-1)
      added.lat <- as.numeric(added.lat)
    } else {added.lat <- as.numeric(added.lat)}
    added.coord <- c(added.long, added.lat)
    if(!is.na(added.lat)&!is.na(added.long)){
    if((distHaversine(loc.coord, added.coord)/1609.34)<25){
      hikes.avail[length(hikes.avail)+1]<-added.id
    } }
  } 
  city.hikes[[id]] <- hikes.avail
}

city.hikes.json <- toJSON(city.hikes)
all.hikes.json <- toJSON(additions)

writeLines(all.hikes.json, "C:/Users/Drummond/Documents/Personal/Weekend/added_total_hikes.json")
writeLines(city.hikes.json, "C:/Users/Drummond/Documents/Personal/Weekend/added_city_hikes.json")
