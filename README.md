# Weekend Plans

This will contain the data and code for "Where should we hike this weekend?"  This may be expanded to include other activities, but is currentlybased on Hiking Upward, National Parks and Monuments, AllTrails.com and the weather, starting in DC.

## Initial build
Once the static data are collected, weather is pulled for areas within driving distance of DC. Once the area or areas with the best hiking weather is determined for the upcoming weekend (closest to sunny, 72 degrees, with a mild breeze), then the ideal hikes are selected from among those in ideal areas. There will be ones within an hour, two hours, and three hours from DC, and then of varying lengths: under five miles, between five and ten, and over ten miles. They will be rated for hilliness of the area or actual elevation change in the hike as well, and selected for best reviews.  This will be first called on Monday of the week for planning purposes, and then updated on Thursday for final decisions.

## Future development
Thoughts of things it should eventually do: 
* On a website, collect the GPS coordinates of the user in order to make localized recommendations
* Get more detailed information about the surrounding geography. Is there anything else we can create with this? Shoreline? Water? Perhaps get water area from Census Tract, or similar? And maybe get some shoreline by getting the west and eastmost locations for particular lines of latitude?
* Other areas of interest, such as museums and historic monuments, and restaurants. I may be able to get some of this from the OpenStreetMaps API. 
* Toggle for distance from current location - we might go futher afield on 3-day weekends. In those cases, perhaps I can collect information about nearby, pet-friendly hotels.
* Get current car-rental prices from [Sabre](https://developer.sabre.com/docs/read/rest_apis/car).
