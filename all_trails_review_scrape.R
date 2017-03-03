if (require(rvest) == FALSE) {
  install.packages('rvest')
  library(rvest)
}

source('https://raw.githubusercontent.com/amydrummond/scrape_functions/master/html_scrape_functions.R')

#### web scraping functions that I should be able to pull from GitHub, but I can't.  
### Look into this JAVA_HOME, eh.

rem.lines <- function(stringstart, stringend, text){
  start.len <- nchar(stringstart)
  start.line <- grep(stringstart, text)[1]
  end.line <- grep(stringend, text)
  end.line <- min(end.line[end.line>=start.line])
  these.lines <- text[start.line:end.line]
  return(these.lines)
}


page.clip <- function(web.text, start.string, end.string){
  start <- (grep(start.string, web.text)[1])+1
  clip <- web.text[start:length(web.text)]
  end <- (grep(end.string, clip)[1]-1)
  final.clip <- clip[1:end]
  return(final.clip)
}

string.clip <- function(string, start.string, end.string){
  start <- regexpr(start.string, string)[1]
  start <- start+(nchar(start.string))
  next.string <- substring(string, start)
  end <- regexpr(end.string, next.string)[1]
  final.string <- substring(next.string, 1, end-1)
  return(final.string)
}

re.request <- function(full.internet.request){
  i <- 0
  j <- 0
  
  while(i==0){
    tryCatch({    j <- j+1 
    api <- full.internet.request
    i <- length(api)}, 
    error = function(e){cat("ERROR :", conditionMessage(e))
      Sys.sleep(10)
      print(paste0("Failure On request ", j))
    })
  }
  return(api)
}

add.list <- function(list, new.element){
  index <- length(list)+1
  list[index] <- new.element
  return(list)
}

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

### AllTrails.com specific function 

get.property <-function(content, metaproperty, start.string, end.string){
  line.no <- grep(metaproperty, content)
  line.content <- content[line.no]
  result <- string.clip(line.content, start.string, end.string)
  return(result)
}

get.metaproperty <-function(content, metaproperty){
  result<- get.property(content, metaproperty,  'content="', '"')
  return(result)
}

#### Pulling the data from alltrails.


at.page <- 'https://www.alltrails.com/trail/us/virginia/four-gorge'
at.trail <- readLines(at.page)

title <- get.metaproperty(at.trail, '<meta property="og:title"')
website <- at.page
difficulty <- get.metaproperty(at.trail, '<meta property="alltrails:difficulty"')
length <- get.metaproperty(at.trail, '<meta property="alltrails:distance"')
latitude <- get.metaproperty(at.trail, '<meta property="alltrails:location:latitude"')
longitude <- get.metaproperty(at.trail, '<meta property="alltrails:location:longitude"')
elevation_gain <- get.metaproperty(at.trail, '<meta property="alltrails:elevation_gain"')
city <- get.metaproperty(at.trail, '<meta property="alltrails:city"')
state <- get.metaproperty(at.trail, '<meta property="alltrails:state"' )
description <- get.metaproperty(at.trail, '<meta property="og:description"')
image.loc <- get.metaproperty(at.trail, '<meta property="og:image"')

activities <- ''
for(act.line in grep('<meta property="alltrails:activities"', at.trail)){
  line.content <- at.trail[act.line]
  result <- string.clip(line.content,'content="', '"')
  activities <- paste(activities, result, sep = ', ')
}
activities <- substring(activities, 3)

rating <- get.property(at.trail, '<span data-react-class="TrailRatingStars"', 'title="', '"' )
total.reviews <- trim(get.property(at.trail, "<span itemprop='reviewCount'>", "<span itemprop='reviewCount'>", '</span>'))
type <- trim(get.property(at.trail, "<span class='route-icon", ">", "<"))


tag.lines <- rem.lines("<section class='tag-cloud'>", '</section>', at.trail)

tags <- ''
for(line in tag.lines){
  if(regexpr('<h3>', line)>0){
    result <- trim(string.clip(line, '<span class="big rounded active">', '</span>'))
    tags <- paste(tags, result, ',')
  }
}

tags <- trim(substring(tags, 2, nchar(tags)-1))




###Now for the reviews:
review.loc <- grep('username&quot;:&quot;', at.trail)
review.string <- at.trail[review.loc]
review.list <- strsplit(review.string, '&quot;id&quot;')
review.list <- review.list[[1]]
rev.count <- length(review.list)
review.list <- review.list[2:rev.count]


l <- 1
num <- 1
parks.list <- data.frame('r_review' = character(), 'r_rating' = character(), 'r_user' = character(), stringsAsFactors = FALSE)
while(l > 0){
  xpathp <- paste0('//*[@id="reviews"]/div[',num,']/div[2]/div[2]/p')
  review <- website  %>%
    read_html() %>%
    xml_nodes(xpath=xpathp)
  review <- as.character(review)
  
  xpathp <- paste0('//*[@id="reviews"]/div[',num,']/div[2]/div[1]/div[1]/span/span')
  ratings <- website  %>%
    read_html() %>%
    xml_nodes(xpath=xpathp)
  ratings <- as.character(ratings)
  
  xpathp <- paste0('//*[@id="reviews"]/div[',num,']/div[2]/div[1]/div[1]/h4/a')
  user <- website  %>%
    read_html() %>%
    xml_nodes(xpath=xpathp)
  user <- as.character(user)
  if(length(user)==0){user<-"Anon"}
  
  parks = data.frame('r_review' = review, 'r_rating' = ratings, 'r_user' =user, stringsAsFactors = FALSE)
  print(parks)
  parks.list <- rbind(parks.list, parks)
  names(parks.list) <- c('r_review', 'r_rating', 'r_user')
  num <- num+1
  l = length(parks)
  if(nrow(parks.list)==20){l<-0}
}

parks.list$review <- "-"
parks.list$rating <- '_'
parks.list$user_id <- '-'
parks.list$user_name <- '-'
i <- 1
while(i <= nrow(parks.list)){
  r_rev <- parks.list$r_review[i]
  rev <- string.clip(r_rev, '>', '<')
  r_rat <- parks.list$r_rating[i]
  rate <- string.clip(r_rat, 'title="', '"')
  r_use <- parks.list$r_user[i]
  if(r_use=='Anon'){
    parks.list$user_id[i]<- 'Anon'
    parks.list$user_name[i]<- 'Anon'
  } else {
    user.id <- string.clip(r_use, 'members/', '"')
    parks.list$user_id[i] <- user.id
    user_name <- string.clip(r_use, 'author', 'span>')
    user_name <- string.clip(user_name, '>', '<')
    parks.list$user_name[i]<- user_name}
  parks.list$review[i] <- rev
  parks.list$user_rating[i] <- rate
  
  i<-i+1
}

parks.list <- data.frame('user' = parks.list$user_id, 'user.name' = parks.list$user_name, 
                         'user_rating' = parks.list$user_rating, 'review' = parks.list$review)

##-- rating //*[@id="reviews"]/div[6]/div[2]/div[1]/div[1]/span/span
##-- member //*[@id="reviews"]/div[1]/div[2]/div[1]/div[1]/h4/a
## reviews: comment : 'comment&quot;:&quot;'
## reviews: userrname : 'username&quot;:&quot;'
## reviews: score : 'rating&quot;:'
