import json
import random

stop_places_path = 'dumps/stop_places.json'
route_numbers_path = 'dumps/route_numbers.json'
route_names_path = 'dumps/route_names.json'
output_path = '../dataset/labeled_dataset.json'

with open(stop_places_path, encoding='utf-8') as file:
    stop_places = json.load(file)
with open(route_numbers_path, encoding='utf-8') as file:
    route_numbers = json.load(file)
with open(route_names_path, encoding='utf-8') as file:
    route_names = json.load(file)

def preprocess_text(text):
    text = text.lower()
    if "?" in text:
        text = text.replace("?", "")
    return text
# training data
def generate_labeled_dataset(stop_places, route_numbers, route_names, num_sentences=1000):
    labeled_data = []

    sentence_examples = [
        "Når kommer {route_number} {route_name} til {stop_place}",
        "Når kommer {route_number} bussen mot {route_name} på {stop_place}",
        "Når er {route_number} mot {route_name} bussen på {stop_place}",
        "Når skal {route_name} {route_number} komme til {stop_place}",
        "Hvilken tidspunkt kommer {route_number} bussen {route_name} til {stop_place}",
        "Når ankommer {route_number} {route_name} på {stop_place}",
        "Når kommer {route_number} bussen på {stop_place} mot {route_name}",
        "Når kommer {route_number} toget mot {route_name}",
        "Jeg skal ta {route_name} bussen som stopper på {stop_place}",
        "Hvilken tid skal {route_name} ankomme {stop_place}",
        "Når vil rute {route_name} ankomme {stop_place}",
        "Jeg skal ta t-banen fra {stop_place}"
        "Jeg står på {stop_place} og skal ta {route_name} bussen. Når kommer den",
        "Når kommer {route_name} trikken på {stop_place}",
        "Hvilken tid ankommer {route_name} toget på {stop_place}",
        "{route_name} på {stop_place}",
        "{route_name} {stop_place}", # if end user were to ask in a very abbreviated way
        "Når kommer {route_name} {route_number}",
        "Hvilken tid kommer {route_number} {route_name}",
        "Jeg vil vite når {route_number} {route_name} kommer",
        "På {stop_place} når vil bussen komme",
        "Når skal kommer bussen på {stop_place}",
        "Når kommer {route_number} bussen",
        "Når kommer {route_name}",
        "Jeg skal ta {route_number} {route_name}",
        "Når kommer {route_number} bussen mot {route_name} fra {stop_place}",
        "Jeg tar {route_name} {route_number}",
        "Jeg skal ta {route_number} toget",
        "Når kommer {route_name} bussen til {stop_place}",
        "Hvilken tid er {route_name} ved {stop_place}",
        "Når går {route_number} bussen fra {stop_place}",
        "Når stopper {route_name} på {stop_place}",
        "Jeg venter på {route_number}, når kommer den til {stop_place}",
        "Når kommer {route_name} linjen til {stop_place}",
        "Hvilken tid skal {route_number} være på {stop_place}",
        "Når passerer {route_name} {stop_place}",
        "Jeg skal ta {route_number}, når er den på {stop_place}",
        "Når kommer {route_name} ruten til {stop_place}",
        "Hvilken tid skal {route_name} toget være på {stop_place}",
        "Når er neste {route_name} buss på {stop_place}",
        "Når ankommer {route_number} toget {stop_place}",
        "Jeg trenger å vite når {route_number} er på {stop_place}",
        "Hvilken tid går {route_name} fra {stop_place}",
        "Når skal {route_name} til {stop_place}",
        "Jeg skal reise med {route_number}, når er den på {stop_place}",
        "Når går {route_name} fra {stop_place}",
        "Hvor lenge til {route_number} er på {stop_place}",
        "Når kommer {route_name} ruten til {stop_place}",
        "Hvilken tid er {route_name} ved {stop_place}",
        "Når er {route_number} planlagt å være på {stop_place}",
        "Når stopper {route_name} på {stop_place}",
        "Hvor lang tid til {route_name} når {stop_place}",
        "Når går {route_number} bussen fra {stop_place}",
        "Hvilken tid ankommer {route_name} på {stop_place}",
        "Når kommer {route_number} til {stop_place}",
        "Når er neste {route_name} rute ved {stop_place}",
        "Når stopper {route_name} bussen på {stop_place}",
        "Hvor lang tid til {route_name} er ved {stop_place}",
        "Når kommer {route_number} toget til {stop_place}",
        "Hvilken tid kommer {route_name} bussen til {stop_place}",
        "Når er {route_number} bussen ved {stop_place}",
        "Når går {route_name} fra {stop_place}",
        "Hvilken tid skal {route_number} være ved {stop_place}",
        "Når passerer {route_name} {stop_place}",
        "Hvor lang tid tar det før {route_number} er på {stop_place}",
        "Når er {route_name} på {stop_place}",
        "Jeg skal ta {route_number}, når stopper den på {stop_place}",
        "Når skal {route_name} være på {stop_place}",
        "Når kommer {route_name} bussen ved {stop_place}",
        "Når stopper {route_number} på {stop_place}?",
        "Når ankommer {route_name} {stop_place}",
        "Når er {route_name} forventet å være på {stop_place}",
        "Når går {route_number} til {stop_place}",
        "Når er {route_name} planlagt å komme til {stop_place}",
        "Når er {route_number} ved {stop_place}"
    ]

    for _ in range(num_sentences):
        stop_place = random.choice(stop_places)
        route_number = str(random.choice(route_numbers))
        route_name = random.choice(route_names)
        sentence_pattern = random.choice(sentence_examples)

        sentence = sentence_pattern.format(route_number=route_number, route_name=route_name, stop_place=stop_place['name'])
        sentence = preprocess_text(sentence) # ensure lowercase

        labeled_sentence = []
        stop_place_words = preprocess_text(stop_place['name']).split() # ensure lowercase and that it recognizes stop place names with whitespace like "Lørenskog Stasjon"
        route_name_words = preprocess_text(route_name).split()

        for word in sentence.split():
            if word == route_number:
                labeled_sentence.append((word, 'B-ROUTENUMBER'))
            elif word in stop_place_words:
                if stop_place_words.index(word) == 0:
                    labeled_sentence.append((word, 'B-STOPPLACE'))
                else:
                    labeled_sentence.append((word, 'I-STOPPLACE'))
            elif word in route_name_words:
                if route_name_words.index(word) == 0:
                    labeled_sentence.append((word, 'B-ROUTENAME'))
                else:
                    labeled_sentence.append((word, 'I-ROUTENAME'))
            else:
                labeled_sentence.append((word, 'O'))
        
        labeled_data.append(labeled_sentence)
        print(labeled_sentence)
        
    return labeled_data

labeled_dataset = generate_labeled_dataset(stop_places, route_numbers, route_names)

print(f"Labeled dataset generated, saving to {output_path}")

with open(output_path, 'w', encoding='utf-8') as file:
    json.dump(labeled_dataset, file, indent=4, ensure_ascii=False)

input()