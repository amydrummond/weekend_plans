import unirest, urllib2, json, codecs, re, string

def rem_parens(string):
    try:
        begin = string.index("(")
        end = string.index(")", beg=begin)
        remove = string[begin:end]
        print remove
        result = string.replace(string, remove, "")
    except:
        result = string
    return result


hikes_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/hike_file.json'

sock = urllib2.urlopen(hikes_url)
total_hikes_json = sock.read()
sock.close()

total_hikes = json.loads(total_hikes_json)

no_url = []
hike_url = {}

correct_no = 0
incorrect = 0

outfile = open('finished_websites_from_guess.txt', 'w')
wrongfile = open('missed_in_website_guess.txt', 'w')

for item in total_hikes.keys():
    rec = total_hikes.get(item)
    rec.get('state')
    sta = rec.get('state')
    try:
        sta = sta.replace(' ', '-')
        sta = sta.encode('ascii', 'ignore')
    except:
        pass
    name = rec.get('name')
    try:
        loc_start = name.index("(")
        loc_end = name.index(")")
        between = name[loc_start:loc_end+1]
        name = name.replace(between, '')
    except:
        pass
    name = re.sub('[^\s\w_-]+', '', name)
    try:
        name = name.replace(' ', '-')
        name = name.encode('ascii', 'ignore')
    except:
        pass
    if 'Park' in str(name):
        ws = 'http://www.alltrails.com/parks/us/' + str(sta) + '/' + str(name)
    else:
        ws = 'http://www.alltrails.com/trail/us/' + str(sta) + '/' + str(name)
    ws = ws.replace('--', '-')
    if ws[len(ws)-1]=='-':
        ws = ws[:len(ws)-1]
    try:
        a=urllib2.urlopen(ws)
        a.getcode()
        a.close()
        correct_no += 1
        hike_url[item]=ws
        print "Website: ", ws
        line = item + '\t' + ws + '\n'
        with open ('finished_websites_from_guess.txt', 'a') as app_file:
            app_file.write(line)
    except IOError, e:
        if hasattr(e, 'code'):
            print "Not a website: ", ws
            print e.code
            incorrect +=1
            no_url.append(item)
            try:
                line = item + '\t' + name + '\t' + sta + '\n'
                with open ('missed_in_website_guess.txt', 'a') as app_file:
                    app_file.write(line)
            except:
                line = item + '\t' + '\t'
                with open ('missed_in_website_guess.txt', 'a') as app_file:
                    app_file.write(line)
        else:
            print "None."
            no_url.append(item)
            line = item + '\t' + name + '\t' + sta + '\n'
            with open ('missed_in_website_guess.txt', 'a') as app_file:
                app_file.write(line)

    print "Websites: ", correct_no
    print "No websites: ", incorrect

