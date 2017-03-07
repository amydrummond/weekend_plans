import unirest, urllib2, json, codecs, re, string, random, time, json

from selenium import webdriver
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from selenium.webdriver.common.by import By

### Check for the presence of an xpath in Selenium.  If the xpath exists, return true; if the xpath does not exist,
### return false.

browser = webdriver.Firefox()
delay = 3 # seconds
def check_exists_by_xpath(driver, xpath):
    try:
        driver.find_element_by_xpath(xpath)
    except NoSuchElementException:
        return False
    return True

print "Pulling in list of towns."
distances_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/distances_file.txt'

sock = urllib2.urlopen(distances_url)
distances_data = sock.read().split('\r\n')
sock.close()

print len(distances_data)

print 'Limiting towns to those within 200 miles of Alexandria, and creating a dictionary.'

distances = {}
for ids in distances_data:
    line = ids.split('\t')
    if len(line) > 1:
        if float(line[1]) <= 321.869:
            distances[line[0]] = line[1]

print len(distances.keys())

print 'Getting location information in order to get town names, latitude and longitude.'

locations_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt'

sock = urllib2.urlopen(locations_url)
locations_data = sock.read().split('\r\n')
sock.close()

print locations_data[:10]

nearby = []
for cities in locations_data:
    line = cities.split('\t')
    if line[0] in distances.keys():
        nearby.append(line)

print len(nearby)

### Finally, pull in All Trails websites that have already been pulled via the API, with a guess or estimation
## of the relevant website. Create a dictionary that relates the website to the trail ID so that the
## list of websites is already handy.

print 'Getting hike websites that already exist so as to not add them a second time.'

existing_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/all_trails_websites.txt'
sock = urllib2.urlopen(existing_url)
existing_data = sock.read().split('\n')
sock.close()

print existing_data[:10]
existing = {}
for trail in existing_data:
    line = trail.split('\t')
    if len(line) > 1:
        existing[str(line[1])] = line[0]

print len(existing.keys())

### This section is only necessary if there's an existing json file to check.
print 'There are existing responses. These will keep from pulling a second time.'

with open('additional_scraped_hikes.json') as data_file:
    added_hikes = json.load(data_file)

for location in nearby:
    this_id = location[0]
    if this_id in added_hikes.keys():
        if len(added_hikes.get(this_id))>0:
            print added_hikes.get(this_id)
            nearby.remove(location)
            print len(nearby)
        else:
            print added_hikes.get(this_id)
    else:
        print len(nearby)

print "Existing locations removed. These are how many records we're looking for:"
print len(nearby)

### Launch Firefox and bring up alltrails.
print "Launching Firefox and getting Selenium. "

driver = webdriver.Firefox()
driver.get('http://www.alltrails.com/')
inputElement = driver.find_element_by_name("q")

try:
    if len(added_hikes.keys())>0:
        print "There are existing hikes."
except:
    print "Creating a new hike file."
    added_hikes = {}

record = 1

for start in nearby:
    counter = 'This is record ' + str(record) + ' of ' + str(len(nearby)) + '.'
    print counter
    id = start[0]
    search_string = start[1] + ' ' + start[5]
    state = start[5]
    state = state.replace(" ", '-').lower()
    town = start[1]
    town_use = town.replace(" ", "-").lower()
    all_string = 'https://www.alltrails.com/explore/us/' + state + '/' + town_use
    try:
        driver.get(all_string)
        try:
            WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, '//*[@id="map"]')))
            print driver.title

            links = []
            division = 1
            cont = 0

            elem = driver.find_element_by_xpath("//*[@id='fullscreen-search-results']/div[1]/h1/a")
            print elem.text
            t = elem.text
            if not town.lower() in t.lower():
                links.append('https://www.sadtrombone.com')
                added_hikes[id] = links
                print "Too bad."
            else:
                while cont == 0:
                    this_path = '//*[@id="fullscreen-search-results"]/ul/div[' + str(division) + ']/a'
                    print this_path
                    try:
                        print this_path
                        added = driver.find_element_by_xpath(this_path).get_attribute('href')
                        print added
                        added = added.replace('/explore/', '/')
                        added = str(added)
                        if added in existing.keys():
                            print "Already exists"
                        else:
                            print "new: ", added
                            links.append(added)
                        division += 1
                    except:
                        cont = 1
                added_hikes[id]=links
                time.sleep(5)
                driver.get("http://www.alltrails.com")
                inputElement = driver.find_element_by_name("q")
        except:
            print "Unable to find a trail"
            time.sleep(5)
    except:
        print "Unable to find trail."
        time.sleep(10)
    record +=1

driver.quit()
with open('next_additional_scraped_hikes.json', 'w') as fp:
    json.dump(added_hikes, fp)


# //*[@id="fullscreen-search-results"]/ul/div[1]/a
# http://www.alltrails.com/explore/us/virginia/ashburn?q=yorktown,%20virginia
# //*[@id="fullscreen-search-results"]/ul/div[2]/a
