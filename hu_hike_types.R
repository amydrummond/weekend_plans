# Hiking upward does not categorize its trails into loops and out-and-back trails.

outpath <- ''  ## chose your preferred directory
filename <- 'hiking_upward_hiketypes.txt'
out.file <- paste0(outpath,filename)

options(stringsAsFactors = FALSE)

if (require(XML) == FALSE) {
  install.packages('XML')
  library(XML)
}

if (require(xml2) == FALSE) {
  install.packages('xml2')
  library(xml2)
}

if (require(dplyr) == FALSE) {
  install.packages('dplyr')
  library(dplyr)
}

if (require(geosphere) == FALSE) {
  install.packages('geosphere')
  library(geosphere)
}

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# This pulls in the existing hiking upward hikes.

hu_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/hiking_upward_hikes.txt'
hu <- read.csv(hu_url, sep = '\t')

hu_types <- data.frame('url' = character(), 'unique' = numeric())
hike_urls = hu$url

## Most hiking upward hikes have .gpx files affiliated. The location is the same as the last file path repeated, then a
## .gpx suffix added.

for(site in hike_urls){
  
  site <- trim(site)
  paths <- gregexpr(pattern ='/',site)
  locs <- length(gregexpr(pattern ='/',site)[[1]])
  end <- paths[[1]][locs]
  begin <- paths[[1]][locs-1]
  added <- substring(site, begin,end)
  added <- substring(added, 2, nchar(added)-1)
  added <- paste0(added, '.gpx')
  gpx.site <- paste0(site, added )
  print(site)
 
 ## some trails don't have .gpx sites. Sort those.
  
  if(length(grep("URL=http://www.hikingupward.com/page_not_found.shtml", readLines(gpx.site))>0)){
    line <- data.frame('url' = site, 'unique' = 5)
    hu_types <- rbind(hu_types, line, make.row.names = FALSE, stringsAsFactors = FALSE)
  } else {
    
    total.wps <- data.frame('waypoint' = character(), 'segment' = numeric())

# Get the waypoints from the .gpx file, which is really just an xml file, and the distance between them.

    xml <- xmlParse(gpx.site)
    
    xmltop <- xmlRoot(xml)
    xnames <- function(xml.path){xmlSApply(xml.path, xmlName)}
    
    route <- xmltop[['rte']]
    route.name <- xmlToList(route[['name']][[1]])
    route.points <- grep('rtept', names(route))
    
    for(item in route.points){
      wp <- xmlAttrs(route[[item]])
      lwp <- xmlAttrs(route[[item-1]])
      if(is.null(lwp)){
        lwp <- xmlAttrs(route[[item]])
      }
      
      str.wp <- paste(wp['lat'], wp['lon'], sep = ', ')
      wp.lon <- as.numeric(wp["lon"][[1]])
      wp.lat <- as.numeric(wp["lat"][[1]])
      wp.geo <- c(wp.lon, wp.lat)
      lwp.lon <- as.numeric(lwp["lon"][[1]])
      lwp.lat <- as.numeric(lwp["lat"][[1]])
      lwp.geo <- c(lwp.lon, lwp.lat)
      dist <- distGeo(wp.geo, lwp.geo)
      df.line <- data.frame( 'waypoint' = str.wp, 'segment' = dist, stringsAsFactors = FALSE)
      total.wps <- rbind(total.wps, df.line, stringsAsFactors = FALSE)
    }
    
    # Now, determine how many segments are repeated, and how many are unique. Sum the distances of the segments 
    # for each and determine what percentage of the trail is walked once, and what percentage of the trail is
    # repeated.
    
    freq.pts <- as.data.frame(table(total.wps$waypoint))
    total.wps <- merge(total.wps, freq.pts, by.x = 'waypoint', by.y = 'Var1')
    by.travel <- group_by(total.wps, Freq)
    dist.repeat <- as.data.frame(summarise(by.travel, 'dist' = sum(segment)))
    once.distance <- dist.repeat[dist.repeat$Freq==1,]$dist
    if(length(once.distance)==0){
      once.distance <- 0
    }
    twice.distance <- dist.repeat[dist.repeat$Freq==2,]$dist
    if(length(twice.distance)==0){
      twice.distance <- 0
    }
    unique.dist <- once.distance/(once.distance+twice.distance)
    
    
    print(unique.dist)
    line <- data.frame('url' = site, 'unique' = unique.dist)
    hu_types <- rbind(hu_types, line, make.row.names = FALSE, stringsAsFactors = FALSE)
    
    
  }
}

# Presenting some maps to a hiker, we determined that 47% or greater unique qualified as a loop trail, while 
# anything less was really an out-and-back.

hu_types$type <- ''
li <- 1
while(li<=nrow(hu_types)){
  if(hu_types$unique[li]>1){
    hu_types$type[li] <- 'Unknown'
  } else if(hu_types$unique[li]>.47){
    hu_types$type[li] <- 'Loop'
  } else {
    hu_types$type[li] <-'Out & Back'
  }
  li <- li+1
}

write.table(hu_types, file = out.file, quote = FALSE, sep = '\t', na = '', row.names = FALSE)
