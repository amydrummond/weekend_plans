file <- ' ' #filelocation
f.key <- ' ' ##forecast.io API key
today <- Sys.Date()
username <- ' ' ###geoid username

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

day.frame <- data.frame(date=c(today, today+1, today+2, today+3, today+4, today+5, today+6))
day.frame$day <- weekdays(as.Date(day.frame$date))
sat <- day.frame[day.frame$day=='Saturday',][[1]]


if (require(jsonlite) == FALSE) {
  install.packages('jsonlite')
  library(jsonlite)
}

lat <- as.character(home[2])
long <- as.character(home[1])

forecast.api.call <- paste('https://api.forecast.io/forecast/', f.key, '/',lat,',',long,',',sat,'T03:00:00',sep = '')
call <- fromJSON(forecast.api.call)
summary <- call[[6]][1]
icon <- call[[6]][2]
details <- call[[6]][[3]]
forecast <- call[[7]][[1]]

geoid = 4744106
place <- 'Alexandria, VA'

weather <- data.frame(geoid, place, elevation, population, distance,  flatten(forecast))
details$id <- geoid
hourly <- details

row = 1
data[row,]
while(row<nrow(data)){
  if(data$dist[row] < 120){
    print(row)
    geoid <- data[row,1]
    lat <- as.character(data$lat[row])
    long <- as.character(data$long[row])
    place <- paste(data$city.name[row], ', ', data$state[row], sep='')
    elev <- data$elevation[row]
    pop <- data$population[row]
    distance <- data$dist[row]
    forecast.api.call <- paste('https://api.darksky.net/forecast/', f.key, '/',lat,',',long,',',sat,'T03:00:00',sep = '')
    call <- fromJSON(forecast.api.call)
    this.summary <- call[[6]][1]
    this.icon <- call[[6]][2]
    this.details <- call[[6]][[3]]
    this.forecast <- call[[7]][[1]]
    this.weather <- data.frame(geoid, place, elev, pop, distance, this.icon, flatten(this.forecast))
    this.details$id <- geoid
    this.hourly <- this.details
    weather <- rbind(weather, this.weather)
    ##    hourly <- rbind(hourly,this.hourly)
  }
  row = row+1
}

### Do hourly like the add.column section from previous based on these columns:
## [1] "time"                "summary"             "icon"                "precipIntensity"    
## [5] "precipProbability"   "temperature"         "apparentTemperature" "dewPoint"           
## [9] "humidity"            "windSpeed"           "windBearing"         "visibility"         
## [13] "cloudCover"          "pressure"            "ozone"               "precipType"         
## [17] "id" 

## sat.total <- sat.total[order((sat.total$max.temp), decreasing = TRUE),]

