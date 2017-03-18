
import urllib2, json, requests

from lxml import html

# For removing all of an unwanted value from a list
def remove_values_from_list(the_list, val):
  x = 1
  item = the_list[x]
  if item == val:
      the_list.remove(item)
      x = x
  else:
      x +=1
  return(the_list)

def string_clip(whole_string, start, finish):
    place_to_start = whole_string.find(start)
    plus = len(start)
    rest = whole_string[place_to_start + plus:].strip()
    end = rest.find(finish)
    done = rest[:end].strip()
    return(done)

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False


## Get data from AT websites

record_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/merged_alltrails_sites.txt'

sock = urllib2.urlopen(record_url)
data_lines = sock.read().split('\r\n')
sock.close()

websites = {}

for row in data_lines:
    line = row.split('\t')
    if(len(line))==2:
        websites[line[0]]=line[1]

parkdata = {}
#site = websites.keys()[1000]
total_hikes = len(websites.keys())

for line in websites.keys():
    if len(websites.get(line))<26:
        del websites[line]


record = 1
no = 0
no_data = []

for site in websites.keys():
    parksite = {}
    state = 'This is record ' + str(record) + ' of ' + str(total_hikes) + '.'
    print state
    url = websites.get(site)
    print url
    sock = urllib2.urlopen(url)
    url_source = sock.read()
    url_page = requests.get(url)
    sock.close()

    try:
        parksite['url']=url

        tree = html.fromstring(url_page.content)
        distance = tree.xpath('//*[@id="trail-stats"]/div/span[1]//text()')[0]
        gain = tree.xpath('//*[@id="trail-stats"]/div/span[2]//text()')[0]
        try:
            rise = (float(gain[0:gain.find(" ")].strip()))/(float(distance[0:distance.find(" ")].strip()))
        except:
            rise = 0

        type = tree.xpath('//*[@id="trail-stats"]/div/span[3]//text()')[0]
        tags = tree.xpath('//*[@id="main"]/div[2]/div[1]/article/section[3]//text()')

        latitude = string_clip(url_source, '<meta property="place:location:latitude" content="', '"')
        longitude = string_clip(url_source, '<meta property="place:location:longitude" content="',  '"')
        location = {}
        location['lat'] = latitude
        location['long'] = longitude

        title = string_clip(url_source, '<meta property="og:title"  content="', '"').replace('&#x27;', "'")
        print title
        image = string_clip(url_source, '<meta property="og:image" content="', '"')
        description = string_clip(url_source, '<meta property="og:description" content="', '"').replace('&#x27;', "'")
        difficulty = string_clip(url_source, "<span class='diff ", ' selected')
        if len(difficulty)>20:
            difficulty =''

        parksite['distance']=distance
        parksite['gain']=gain
        parksite['rise']=rise
        parksite['type']=type
        parksite['location']=location
        parksite['title']=title
        parksite['image']=image
        parksite['description']=description
        parksite['difficulty']=difficulty


        i = 0


        while i < len(tags):
            if tags[i][0]=='\n':
                tags.remove(tags[i])
                i = i-1
            else:
                i +=1

        parksite['tags']=tags

        rating = float(string_clip(url_source, '<meta itemprop="ratingValue" content="', '" />'))
        num_ratings = int(string_clip(url_source, "<span itemprop='reviewCount'>", "</span>" ))

        parksite['rating']=rating
        parksite['num_ratings']=num_ratings

        l = 1
        num = 1
        reviews = []
        while(l > 0):
            review_contents = {}
            rev = '//*[@id="reviews"]/div[' + str(num) + ']/div[2]/div[1]//text()'
            if len(tree.xpath(rev))>0:
                reviewer = tree.xpath(rev)[0]
                if (tree.xpath(rev)[1][0]).isdigit():
                    recency = tree.xpath(rev)[1]
                    activity = ''
                else:
                    recency = tree.xpath(rev)[2]
                    activity = tree.xpath(rev)[1]
                time_gap = int(recency[0:recency.find(" ")])
                time_interval = recency[recency.find(" "):].strip()
                time_interval = time_interval[:time_interval.find(" ")].strip()

                full = '//*[@id="reviews"]/div[' + str(num) + ']/div[2]/div[1]/div[1]/span/span'
                result = tree.xpath(full)
                p_rating = float(result[0].get('title'))
                review_xpath = '//*[@id="reviews"]/div['+str(num)+']/div[2]/div[2]/p//text()'
                try:
                    review_text = tree.xpath(review_xpath)[0]
                    review_text = review_text
                except:
                    review_text = ''
                review_contents['reviewer']=reviewer
                review_contents['activity']=activity
                review_contents['rates']=p_rating
                review_contents['text']=review_text
                reviews.append(review_contents)
                num += 1
            else:
                l = 0
        parksite['reviews'] = reviews
        parksite['data']='all data'

        parkdata[site]=parksite
    except:
        parksite['url'] = url
        parksite['data']= 'incomplete data'
        parkdata[site]=parksite
        no +=1
        no_data.append(url)

    record +=1

with open('at_hike_data.json', 'w') as fp:
    json.dump(parkdata, fp)

with open('no_data.json', 'w') as d:
    json.dump(parkdata, d)
