##Collect previous AllTrails websites.
import unirest, urllib2, json, codecs, re, string, random, time, json


existing_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/all_trails_websites.txt'
sock = urllib2.urlopen(existing_url)
existing_data = sock.read().split('\n')
sock.close()

print existing_data[:10]
existing_sites = {}
existing_trails = {}

for trail in existing_data:
    line = trail.split('\t')
    if len(line) > 1:
        existing_sites[str(line[1]).lower()] = line[0]
        existing_trails[line[0]] = str(line[1])

with open('next_additional_scraped_hikes.json') as data_file:
    added_hikes = json.load(data_file)


unique_urls = {}

for location in added_hikes.keys():
    hikes = added_hikes.get(location)
    for hike in hikes:
        unique_urls[str(hike)]=location

all_nearby_at_hikes = unique_urls.keys()
print(len(all_nearby_at_hikes))

print all_nearby_at_hikes[:10]
print len(added_hikes.keys())

for hike in all_nearby_at_hikes:
    if hike in existing_sites.keys():
        all_nearby_at_hikes.remove(hike)


print len(all_nearby_at_hikes)

new_hikes = {}
no = 1000001
for ws in all_nearby_at_hikes:
    trail_no = "AT_" + str(no)
    new_hikes[trail_no]=ws
    no += 10

print len(new_hikes.keys())

for trail in existing_trails.keys():
    ws = existing_trails.get(trail)
    line = trail + '\t' + ws + '\n'
    with open('merged_alltrails_sites.txt', 'a') as app_file:
        app_file.write(line)

print len(existing_trails.keys())

for trail in new_hikes.keys():
    ws = new_hikes.get(trail)
    line = trail + '\t' + ws + '\n'
    with open('merged_alltrails_sites.txt', 'a') as app_file:
        app_file.write(line)


print len(new_hikes.keys()) + len(existing_trails.keys())




