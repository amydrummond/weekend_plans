import math, urllib2, os

exportfile_location = "C:/Users/Drummond/Documents/Personal/Weekend/"

## How hilly is a place? This gets coordinates for eight locations
# a kilometer away, at 45 degree bearings, as well as eight locations
# two kilometers away.

# Then, this gets the elevations for those coordinates

# This gets the coordinates for places 

base_url = 'https://raw.githubusercontent.com/amydrummond/weekend_plans/master/data_sources/location_information.txt'

sock = urllib2.urlopen(base_url)
data_lines = sock.read().split('\n')
sock.close()

data = []
for line in data_lines:
    data.append(line.split('\t'))
    

R = 6378.1 #Radius of the Earth

def calculateDistance(lat1, lon1, lat2, lon2):
    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = (math.sin(dlat/2))**2 + math.cos(lat1) * math.cos(lat2) * (math.sin(dlon/2))**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = R * c
    return distance

def exportFile(list_for_file, path_and_filename):
    file_data = ''
    for record in list_for_file:
        fields = ''
        for field in record:
            fields = fields + '\t' +  str(field)
        fields = fields[1:]
        line = fields + '\n'
        file_data += line
    with open(path_and_filename, "w") as export_file:
        export_file.write(file_data)


# Get bearings for cardinal directions
bearings = [45]
i = len(bearings)
while i <8:
    add = bearings[i-1] + 45
    bearings.append(add)
    i = len(bearings)

#convert to radians
r_bearings =[]
for item in bearings:
    rad = math.radians(item)
    r_bearings.append(rad)

d1 = 1
d2 = 2

alexandria_lat = 38.807483
alexandria_lon = -77.070731

coordinates = {}

distances = []

for data_ref in data[1:-1]:
#    print data_ref[1]
    data_id = data_ref[0]
    data_lon = float(data_ref[3])
    data_lat = float(data_ref[4])

    distance = calculateDistance(alexandria_lat, alexandria_lon, data_lat, data_lon)
    distances.append((data_id, distance))
    
    coordinates_list = []
   

    for bearing in r_bearings:
        r_lat = math.radians(data_lat)
        r_lon = math.radians(data_lon)

        d_lat = math.asin( math.sin(r_lat)*math.cos(d1/R) +
         math.cos(r_lat)*math.sin(d1/R)*math.cos(bearing))

        d2_lat = math.asin( math.sin(r_lat)*math.cos(d2/R) +
         math.cos(r_lat)*math.sin(d2/R)*math.cos(bearing))

        d_lon = r_lon + math.atan2(math.sin(bearing)*math.sin(d1/R)*math.cos(r_lat),
                 math.cos(d1/R)-math.sin(r_lat)*math.sin(d_lat))

        d2_lon = r_lon + math.atan2(math.sin(bearing)*math.sin(d2/R)*math.cos(r_lat),
                 math.cos(d2/R)-math.sin(r_lat)*math.sin(d2_lat))

        dist1 = (math.degrees(d_lat), math.degrees(d_lon))
        dist2 = (math.degrees(d2_lat), math.degrees(d2_lon))

        coordinates_list.append(dist1)
        coordinates_list.append(dist2)
    coordinates[data_id] = coordinates_list

print "Coordinates calculated."
##

c = 1
coord_string = []
while c < len(data[:-1]):
    this = coordinates.get(data[c][0])
    search_string = ''
    for tup in this:
        strin = str(tup[0])+","+str(tup[1])+"|"
        search_string = search_string + strin
    search_string = search_string[:-1]
    coord_string.append([data[c][0],search_string])
    c +=1
print "Converted to strings."

distance_file = exportfile_location + "distances_file.txt"
coordinates_file = exportfile_location + "coordinates_file.txt"
exportFile(distances, distance_file)
exportFile(coord_string, coordinates_file)
           
