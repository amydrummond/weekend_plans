# Data sources
## Static sources
Some data do not need to be updated or refreshed: the location information for where weather data are available are static data from
http://openweathermap.org can be downloaded from http://bulk.openweathermap.org/sample/. 

In order to create a basefile, I combined this with elevation and population information from http://geonames.org. Geonames.org requires a username and is rate-limited -- the script that added population and elevation data pulls no faster than every two seconds.

The first file, [location_information](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt), was created by the [create_location_basefile](https://github.com/amydrummond/weekend_plans/blob/master/create_location_basefile.R) script, and serves as the basefile for additional goegraphical information.

A second script, [get_nearby_coordiantes](https://github.com/amydrummond/weekend_plans/blob/master/get_nearby_coordinates.py), creates coordinate strings for each location. The idea is to get coordinates for eight locations 1 km, at 45 degree bearing increments, and then the same for 2 km distance. The resulting coordinates for sixteen nearby locations are then saved as a string in the [coordinates_file](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/coordinates_file.txt) that can be used by the Google elevation API. I'm trying to get the hilliness of the area. 
