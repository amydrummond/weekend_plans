# Data sources
## Static sources
Some data do not need to be updated or refreshed: the location information for where weather data are available are static data from
http://openweathermap.org can be downloaded from http://bulk.openweathermap.org/sample/. 

In order to create a basefile, I combined this with elevation and population information from http://geonames.org. Geonames.org requires a username and is rate-limited -- the script that added population and elevation data pulls no faster than every two seconds.

The first file, [location_information](https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt), was created by the [create_location_basefile](https://github.com/amydrummond/weekend_plans/blob/master/create_location_basefile.R) script, and serves as the basefile for additional goegraphical information.


