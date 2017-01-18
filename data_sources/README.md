# Data sources
## Static sources
Some data do not need to be updated or refreshed: the location information for where weather data are available are static data from
http://openweathermap.org can be downloaded from http://bulk.openweathermap.org/sample/. 

In order to create a basefile, I combined this with elevation and population information from http://geonames.org. Geonames.org requires a username and is rate-limited -- the script that added population and elevation data pulls no faster than every two seconds.

The first file, [location_information](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt), was created by the [create_location_basefile](https://github.com/amydrummond/weekend_plans/blob/master/create_location_basefile.R) script, and serves as the basefile for additional goegraphical information.

A second script, [get_nearby_coordiantes](https://github.com/amydrummond/weekend_plans/blob/master/get_nearby_coordinates.py), creates coordinate strings for each location. The idea is to get coordinates for eight locations 1 km, at 45 degree bearing increments, and then the same for 2 km distance. The resulting coordinates for sixteen nearby locations are then saved as a string in the [coordinates_file](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/coordinates_file.txt) that can be used by the Google elevation API. I'm trying to get the hilliness of the area. 

I do this in [hilliness_information.txt](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/hilliness_information.txt), which was created from the [hilliness](https://github.com/amydrummond/weekend_plans/blob/master/hilliness.R) script. Since this script utilizes the gmaps API, with a rate limit of 2,500 calls a day, I limited this to areas within 200 miles of Washington, DC. This will eventually be updated with national information.

I have added hikes from [AllTrails.com](http://www.alltrails.com/) using [all_trails_data_acqusition](https://github.com/amydrummond/weekend_plans/blob/master/all_trails_data_acquisition.py) ([file](https://github.com/amydrummond/weekend_plans/blob/master/data_sources/hike_file.json)), and [Hiking Upward](http://www.hikingupward.com/), [National Monuments](https://en.wikipedia.org/wiki/List_of_National_Monuments_of_the_United_States), [National Parks](https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States), and [UNESCO World Heritage Sites](https://en.wikipedia.org/wiki/List_of_World_Heritage_Sites_in_the_Americas) using [national_parks_and_hiking_upward_acquitision](https://github.com/amydrummond/weekend_plans/blob/master/national_parks_and_hiking_upward_acquisition.R)([file](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/added_total_hikes.json)).  I have again limited these to destinations within 200 miles of Washington DC. The data scraped from Wikipedia and Hiking Upward is a bit messy; I might want to go through and clean this up. There are [two](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/added_city_hikes.json) [files](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/added_city_hikes.json) matching weather basefile geographies with the hikes within 25 miles. 

I then combined the hikes files into a [merged hike file](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/merged_hike_file.json) and merged the locations files via [combine_hike_files](https://github.com/amydrummond/weekend_plans/blob/master/combine_hike_files.py) into [total_city_hikes](https://github.com/amydrummond/weekend_plans/blob/master/data_sources/total_city_hikes.json).

The AllTrails API does not include reviews, so those will have to be scraped from the website. However, the xpaths are pretty reliable, and can be scraped using this script:  
```R

parks.url <- "http://www.alltrails.com/trail/us/virginia/washington-and-old-dominion-trail-wod"
l <- 1
num <- 1
parks.list <- list()
while(l > 0){
  xpathp <- paste0('//*[@id="reviews"]/div[',num,']/div[2]/div[2]/p')
  parks <- parks.url  %>%
    read_html() %>%
    xml_nodes(xpath=xpathp)
  parks <- as.character(parks)
  print(parks)
  parks.list <- c(parks.list, parks)
  num <- num+1
  l = length(parks)
}
```
I'll have to work out getting the urls -- it looks like it's string based on the name of the hike, although shorted tp 50 characters including the /us/[state]/. Hiking Upward can be scraped with largely the same script as previously; it looks like the review table is accessible through an xpath.

#####Update    
I tested the statuses for this method:
```python
for item in total_hikes.keys():
	rec = total_hikes.get(item)
	rec.get('state')
	sta = rec.get('state')
	try:
		sta = sta.replace(' ', '-')
	except:
		pass
	name = rec.get('name')
	try:
		name = name.replace(' ', '-')
	except:
		pass
	if 'park' in str(name):
		ws = 'http://www.alltrails.com/parks/us/' + str(sta) + '/' + str(name)
	else:
		ws = 'http://www.alltrails.com/trail/us/' + str(sta) + '/' + str(name)
	try:
		a=urllib2.urlopen(ws)
		a.getcode()
		a.close()
		correct_no += 1
		correct.append(ws)
	except IOError, e:
		if hasattr(e, 'code'):
			print e.code
			incorrect +=1
		else:
			print "None."
 ```
Fewer than 30% return a status code of 200.  I'll have to try something else.  

That should do it for static data. 

##Dynamic sources
The dynamic sources are the weather sources, which are available through weather APIs: http://openweathermap.org and [forecast.io] (https://darksky.net/dev/). I have started working on the weather aquisition scripts in [forecast_io_reader] (https://github.com/amydrummond/weekend_plans/blob/master/forecast_io_reader.R) and [bringing_in_weather](https://github.com/amydrummond/weekend_plans/blob/master/bringing_in_weather.R). These are rough, at the moment, and aren't connected to the location file. Additionally, for dynamic interaction that can be run out of GitHub, I'll probably want to rewrite the scripts in Python.
