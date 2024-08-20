from transformers import BertTokenizerFast, BertForTokenClassification

model = BertForTokenClassification.from_pretrained("../model")
tokenizer = BertTokenizerFast.from_pretrained('bert-base-multilingual-cased')

test_sentence = "når kommer 17 trikken på universitetet blindern"
print("Input: ", test_sentence, "\n press any key to continue:")
input()

inputs = tokenizer(test_sentence, return_tensors="pt")

outputs = model(**inputs)
predictions = outputs.logits.argmax(dim=-1)

# integers back to label names
label_mapping = {0: "O", 1: "B-ROUTENUMBER", 2: "B-ROUTENAME", 3: "I-ROUTENAME", 4: "B-STOPPLACE", 5: "I-STOPPLACE"}
predicted_tags = [label_mapping[label_id.item()] for label_id in predictions[0]]

# convert token ids back to words
tokens = tokenizer.convert_ids_to_tokens(inputs["input_ids"][0])
    
# merge the subwords    
merged_tokens = []
merged_tags = []

for token, tag in zip(tokens, predicted_tags):
    if token.startswith("##"):
        merged_tokens[-1] += token[2:] # add the subword to previous token
    else:
        merged_tokens.append(token)
        merged_tags.append(tag)


route_name, route_number, stop_place = "", -999, ""

for token, tag in zip(merged_tokens, merged_tags): # merged meaning merged after possible split-ups of tokens in tokenization
    print(f"{token}: {tag}")
    if tag == "B-ROUTENAME" or tag == "I-ROUTENAME":
        route_name = route_name + " " + token
    elif tag == "B-ROUTENUMBER":
        route_number = int(token)
    elif tag == "B-STOPPLACE" or tag == "I-STOPPLACE":
        stop_place = stop_place + " " + token

if route_name == "":
    route_name = "route name not found"
if stop_place == "":
    stop_place = "stop place not found"

print("Route Number: ", route_number)
print("Route Name: ", route_name)
print("Stop Place Name: ", stop_place)

print("Done.")
input()