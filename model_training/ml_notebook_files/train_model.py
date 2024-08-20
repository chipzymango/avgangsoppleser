#!/usr/bin/env python
# coding: utf-8

# In[ ]:


get_ipython().system('jupyter nbconvert "/content/drive/MyDrive/Colab Notebooks/AnkomstOppleser/train_model.ipynb" --to python')


# In[1]:


get_ipython().system('pip install datasets')
from transformers import BertTokenizerFast, BertForTokenClassification, Trainer, TrainingArguments
import os
os.chdir('/content/drive/MyDrive/Colab Notebooks/AnkomstOppleser')
from prepare_dataset import dataset
from datasets import load_dataset, load_metric, DatasetDict, Dataset
from sklearn.model_selection import train_test_split

tokenizer = BertTokenizerFast.from_pretrained('bert-base-multilingual-cased')
model = BertForTokenClassification.from_pretrained('bert-base-multilingual-cased', num_labels=6)

def tokenize_and_align_labels(examples):
    tokenized_inputs = tokenizer(examples["tokens"], truncation=True, padding=True, is_split_into_words=True)

    labels = []
    for i, label in enumerate(examples["ner_tags"]):
        word_ids = tokenized_inputs.word_ids(batch_index=i)
        label_ids = []
        previous_word_id = None
        for word_id in word_ids:
            if word_id is None or word_id in ["CLS", "SEP", "PAD"]:
                label_ids.append(-100)
            elif word_id != previous_word_id:
                label_ids.append(label[word_id])
            else:
                label_ids.append(-100)
            previous_word_id = word_id

        labels.append(label_ids)

    tokenized_inputs["labels"] = labels
    return tokenized_inputs

tokenized_dataset = dataset['train'].map(tokenize_and_align_labels, batched=True)

# split data into training and evaluation data
train_data, val_data = train_test_split(dataset['train'], test_size = 0.2)

# convert new splits into datasets objects each
train_dataset = Dataset.from_dict(train_data)
val_dataset = Dataset.from_dict(val_data)

train_dataset = DatasetDict({"train": train_dataset})
val_dataset = DatasetDict({"val": val_dataset})

tokenized_datasets = {
    "train": train_dataset['train'].map(tokenize_and_align_labels, batched=True),
    "validation": val_dataset['val'].map(tokenize_and_align_labels, batched=True)
}

# training arguments
training_args = TrainingArguments(
    output_dir = "./output",
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    num_train_epochs=10,
    weight_decay=0.01,
)

# initialize trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["validation"],
    tokenizer=tokenizer
)

trainer.train()

print("Training completed. Saving...")

trainer.save_model("fine-tuned-ner-model")

eval_results = trainer.evaluate()
print("Evaluation results: ", eval_results)



# In[ ]:


pip install datasets

