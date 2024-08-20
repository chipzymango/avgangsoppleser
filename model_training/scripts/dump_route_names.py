import json
from pathlib import Path
import xmltodict

path = Path("rb_rut-aggregated-netex") # folder containing all lines from Ruter ('https://developer.entur.org/stops-and-timetable-data' under "Time table data")
output_path = "dumps/route_names.json"

route_names = []

def extract_route_names():
    for child in path.iterdir():
        print("In: ", child)
        with open(child, 'r', encoding='utf-8') as file:
            xml = file.read()
            route_info = xmltodict.parse(xml, encoding='utf-8')

            route_info = route_info["PublicationDelivery"]["dataObjects"]["CompositeFrame"]["frames"]["TimetableFrame"]["vehicleJourneys"]["ServiceJourney"]#.split("-", 9)

            for r in route_info:
                try:
                    name = r["Name"]
                    if name not in route_names:
                        print("     Found:", name)
                        name = name.replace("–","-").replace(".", "")
                        
                        route_names.append(name)
                except:
                    print('Failed to get ["Name"] in this one. Skipping...')

    with open(output_path, "w", encoding='utf-8') as file:
        json.dump(route_names, file, indent=4, ensure_ascii=False)

    print(f"\nSaved to '{output_path}'")

extract_route_names()

input()