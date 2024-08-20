import json
from pathlib import Path

path = Path("rb_rut-aggregated-netex") # folder containing all lines from Ruter ('https://developer.entur.org/stops-and-timetable-data' under "Time table data")
output_path = "dumps/route_numbers.json"

route_numbers = []

def extract_route_numbers():
    for child in path.iterdir():
        child = str(child).split("-", 3)[3].rsplit("_", 2)[0].split("-")[1]
        print(child)
        route_numbers.append(int(child))
               
    with open(output_path, "w", encoding='utf-8') as file:
        json.dump(route_numbers, file, indent=4, ensure_ascii=False)

    print(f"Saved to '{output_path}'")

extract_route_numbers()

input()