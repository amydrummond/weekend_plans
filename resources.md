EveryTrail -- This will give the search box by activity and latitude and longitude:

## http://www.everytrail.com/trip/search?q=&address=&activities%5B%5D=2&activities%5B%5D=39&activities%5B%5D=3&activities%5B%5D=5&activities%5B%5D=11&activities%5B%5D=33&activities%5B%5D=9&activities%5B%5D=22&activities%5B%5D=12&activities%5B%5D=23&activities%5B%5D=13&lon=-77.070731&lat=38.807483&proximity=5&min_length=0.1&max_length=&min_duration=0&max_duration=0&sent=true
### There's a typo that will make it easy to find the start of the descriptions: &lt;div classs="container"&gt;

This turns out to be unnecessary. Everytrail has an API - 

http://devwiki.everytrail.com/index.php/Searching_Trips

state parks -- https://en.wikipedia.org/wiki/Lists_of_state_parks_by_U.S._state

http://open.mapquestapi.com/xapi/api/0.6/node[amenity=restaurant][bbox=-77.1,38.75,-77.0,38.85]?key=<<KEY>>
  -- will need to figure out a good scheme for creating an appropriate bounding box (inverse on population?)
  -- pull multiple nodes = leisure, natural, tourism
  
  Car rental, etc - https://developer.sabre.com/docs/read/rest_apis/car
  
