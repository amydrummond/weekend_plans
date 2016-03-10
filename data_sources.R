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

monuments.url <- "https://en.wikipedia.org/wiki/List_of_National_Monuments_of_the_United_States"
monuments <- monuments.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[3]') %>%
  html_table()
monuments <- monuments[[1]]
monuments <- transform(monuments, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
monuments <- transform(monuments, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
monuments <- transform(monuments, coordinates = colsplit(location.decimal, pattern = "ï»¿ ", c("decimal", "name")))
monuments <- transform(monuments, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

monuments <- data.frame('name' = monuments$National.Monument.Name, 'state' = monuments$state.state, 
                             'latitude' = monuments$coord.latitude, 'longitude' = monuments$coord.longitude, 'description' = monuments$Description)

parks.url <- "https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States"
parks <- parks.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%
  html_table()
parks <- parks[[1]]
parks <- transform(parks, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
parks <- transform(parks, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
parks <- transform(parks, coordinates = colsplit(location.decimal, pattern = "ï»¿ ", c("decimal", "name")))
parks <- transform(parks, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

parks <- data.frame('name' = parks$Name, 'state' = parks$state.state, 
                        'latitude' = parks$coord.latitude, 'longitude' = parks$coord.longitude, 'description' = parks$Description)


heritage.url <- "https://en.wikipedia.org/wiki/List_of_World_Heritage_Sites_in_the_Americas"
heritage <- heritage.url  %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%
  html_table()
heritage <- heritage[[1]]
heritage <- transform(heritage, location = colsplit(Location, pattern = " / ", c("state", "degree", "decimal") ))
heritage <- transform(heritage, state = colsplit(location.state, pattern = '\n', c("state", "gook")))
heritage <- transform(heritage, coordinates = colsplit(location.decimal, pattern = "ï»¿ ", c("decimal", "name")))
heritage <- transform(heritage, coord = colsplit(coordinates.decimal, pattern = "; ", c("latitude", "longitude")))

heritage <- data.frame('name' = heritage$Site, 'state' = heritage$state.state, 
                    'latitude' = heritage$coord.latitude, 'longitude' = heritage$coord.longitude, 'description' = heritage$Description)

heritage.usa <- heritage[substring(heritage$state, 1, 13)== 'United States',]
heritage.usa$state <- substring(heritage.usa$state,14)
heritage.usa$state <- substring(heritage.usa$state, 1, nchar(heritage.usa$state)-1)

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
