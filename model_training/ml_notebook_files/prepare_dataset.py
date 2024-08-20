#!/usr/bin/env python
# coding: utf-8

# In[4]:


get_ipython().system('jupyter nbconvert "/content/drive/MyDrive/Colab Notebooks/AnkomstOppleser/prepare_dataset.ipynb" --to python')


# In[1]:


get_ipython().system('pip install datasets')
from datasets import Dataset, DatasetDict
import json
import os
os.chdir('/content/drive/MyDrive/Colab Notebooks/AnkomstOppleser')

# forward string labels to integers for ner model
label_mapping = {"O": 0, "B-ROUTENUMBER": 1, "B-ROUTENAME": 2, "I-ROUTENAME": 3, "B-STOPPLACE": 4, "I-STOPPLACE": 5}

path = 'labeled_dataset.json'
with open(path, encoding='utf-8') as file:
    labeled_dataset = json.load(file)

data = {"tokens": [], "ner_tags": []}

for sentence in labeled_dataset:
    tokens = [str(word) for word, tag in sentence]
    ner_tags = [label_mapping.get(tag, 0) for word, tag in sentence]

    data["tokens"].append(tokens)
    data["ner_tags"].append(ner_tags)

# convert to dataset and then datasetdict
dataset = Dataset.from_dict(data)
dataset = DatasetDict({"train": dataset})

print("Dataset prepared")



# In[ ]:


get_ipython().system('jupyter nbconvert prepare_dataset.ipynb --to python')

