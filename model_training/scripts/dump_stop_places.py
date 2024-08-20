import xml.etree.ElementTree as ET
import json
import random

# imported 8/11/2024
# can be found from https://developer.entur.org/stops-and-timetable-data under "Stops and quays per region"
oslo_export = "03_Oslo_latest/tiamat-export-03_Oslo-202408111200160167.xml"
akershus_export = "32_Akershus_latest/tiamat-export-32_Akershus-202408111200537901.xml"

exports = {'Oslo': oslo_export, 'Akershus': akershus_export}

output_path = 'dumps/stop_places.json'

stop_places = []

stop_places_found = 0

namespaces = {
    'netex': "http://www.netex.org.uk/netex",
    'gml': "http://www.opengis.net/gml/3.2"
}
a=0
for i in range(len(exports)):
    tree = ET.parse(list(exports.values())[i])
    root = tree.getroot()

    for stop_place in root.findall('.//netex:StopPlace', namespaces):
        name = stop_place.find('netex:Name', namespaces).text
        lat = float(stop_place.find('netex:Centroid/netex:Location/netex:Latitude', namespaces).text)
        long = float(stop_place.find('netex:Centroid/netex:Location/netex:Longitude', namespaces).text)
        county = list(exports.keys())[i]
        #stop_place_type = stop_place.find('netex:StopPlaceType', namespaces).text

        stop_places.append({
            'name': name,
            'lat': lat,
            'long': long,
            'county': county
        })

        stop_places_found += 1

        print(f"{name}, {lat}, {long}, {county}")

print(f"{stop_places_found} stop places were collected. dumping...")

with open(output_path, 'w', encoding='utf-8') as file:
    json.dump(stop_places, file, indent=4, ensure_ascii=False)

print(f"dump is complete and can be found at '{output_path}'")