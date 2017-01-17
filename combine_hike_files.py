import unirest, urllib2, json
from collections import defaultdict


original_hikes_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/city_area_hikes.json'
add_hikes_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/added_city_hikes.json'

sock = urllib2.urlopen(original_hikes_url)
original_hikes = sock.read()
sock.close()

sock = urllib2.urlopen(add_hikes_url)
added_hikes = sock.read()
sock.close()

original_hikes_json = json.loads(original_hikes)
added_hikes_json = json.loads(added_hikes)

combined = defaultdict(list)
for d in (original_hikes_json, added_hikes_json):
    for key, value in d.iteritems():
        combined[key].append(value)

with open('total_city_hikes.json', 'w') as fp:
    json.dump(combined, fp)

