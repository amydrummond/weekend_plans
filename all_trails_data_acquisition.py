# These code snippets use an open-source library. http://unirest.io/python

import unirest, urllib2, json

record_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/hilliness_information.txt'
api_key = " " ### API key for alltrails.com goes here

sock = urllib2.urlopen(record_url)
data_lines = sock.read().split('\n')
sock.close()

data = []
for line in data_lines:
    data.append(line.split('\t'))

total_hikes = {}
loc_hikes = {}
total_keys = {}

for city in data[:-1]:
    city_id = city[0]
    lon = city[3]
    lat = city[4]
    loc = city[1] + ", " + city[5]
    print loc

    api_call = "https://trailapi-trailapi.p.mashape.com/?lat="+lat+"&lon="+lon+"&q[activities_activity_type_name_eq]=hiking&radius=25"

    response = unirest.get(api_call,
      headers={
        "X-Mashape-Key": api_key,
        "Accept": "text/plain"
      }
    )

    print response.code

    places = response.body.get('places')
    no_places = len(response.body.get('places'))

    id_list = []
    for no, places in enumerate(response.body.get('places')):
        id = 'AT_' + str(response.body.get('places')[no].get('unique_id'))
        id_list.append(id)
        total_hikes[id]=places
        for label in response.body.get('places')[no].keys():
            total_keys[label]=1

    loc_hikes[city_id]=id_list

with open('city_area_hikes.json', 'w') as fp:
    json.dump(loc_hikes, fp)

with open('hike_file.json', 'w') as fp:
    json.dump(total_hikes, fp)
                
