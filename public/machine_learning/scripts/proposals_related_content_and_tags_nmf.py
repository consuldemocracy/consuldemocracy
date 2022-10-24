#!/usr/bin/env python
# coding: utf-8

# In[1]:


"""
Related Proposals and Tags

This script generates for each proposal: a) Tags, b) List of related proposals.
Running time: Max 2 hours for 10.000 proposals.
Technique used: NNMF and Euclidean distance between proposals.
More info in: https://github.com/consul-ml/consul-ml
"""


# In[ ]:


def check_file(file_name):
    if os.path.isfile(file_name):
        return
    else:
        try:
            logging.info('Missing file in Related Proposals and Tags: ' + str(file_name))
        except NameError:
            print('No logging')            
        with open(os.path.join(data_path,taggings_filename), 'w') as file:
            file.write('[]')
        with open(os.path.join(data_path,tags_filename), 'w') as file:
            file.write('[]')
        with open(os.path.join(data_path,related_props_filename), 'w') as file:
            file.write('[]')
        os._exit(0)


# In[ ]:


# Input file:
inputjsonfile = 'proposals.json'
col_id = 'id'
col_title = 'title'
cols_content = ['title','description','summary']

# Output files:
topics_tags_filename = 'ml_topics_tags_proposals.json'
topics_tags_filename_csv = 'ml_topics_tags_proposals.csv'

repr_prop_filename = 'ml_repr_proposals.json'
repr_prop_filename_csv = 'ml_repr_proposals.csv'

taggings_filename = 'ml_taggings_proposals.json'
taggings_filename_csv = 'ml_taggings_proposals.csv'

tags_filename = 'ml_tags_proposals.json'
tags_filename_csv = 'ml_tags_proposals.csv'

related_props_filename = 'ml_related_content_proposals.json'
related_props_filename_csv = 'ml_related_content_proposals.csv'

tqdm_notebook = True


# In[2]:


data_path = '../data'
config_file = 'proposals_related_content_and_tags_nmf.ini'
logging_file ='proposals_related_content_and_tags_nmf.log'

# Read the configuration file
import os
import configparser
config = configparser.ConfigParser()
check_file(os.path.join(data_path,config_file))
config.read(os.path.join(data_path,config_file))

stanza_model_lang = config['PREPROCESSING']['stanza_model_lang']
stopwords_lang = config['PREPROCESSING']['stopwords_lang']
noun_lemmatisation = config['PREPROCESSING'].getboolean('noun_lemmatisation')
n_gram_min_count = config['PREPROCESSING'].getint('n_gram_min_count')
stanza_download = config['PREPROCESSING'].getboolean('stanza_download')
nltk_download = config['PREPROCESSING'].getboolean('nltk_download')

numb_related_proposals = config['RELATED_PROPOSALS'].getint('numb_related_proposals')

numb_topics = config['TOPIC_MODELLING'].getint('numb_topics')
numb_topkeywords_pertopic = config['TOPIC_MODELLING'].getint('numb_topkeywords_pertopic')
n_top_represent_props = config['TOPIC_MODELLING'].getint('n_top_represent_props')
n_features = config['TOPIC_MODELLING'].getint('n_features')
min_df_val = config['TOPIC_MODELLING'].getfloat('min_df_val')
max_df_val = config['TOPIC_MODELLING'].getfloat('max_df_val')

logging_level = config['LOGGING']['logging_level']


# In[3]:


related_props_cols = ['id']+['related'+str(num) for num in range(1,numb_related_proposals+1)]

repr_prop_cols = ['topic_id','proposal_id','title']
tags_file_cols = ['id','name','taggings_count','kind']
taggings_file_cols = ['tag_id','taggable_id','taggable_type']
tag_cols = ['tag'+str(num) for num in range(1,numb_topkeywords_pertopic+1)]

tags_file_cols_count = 'taggings_count'
taggings_file_cols_id = 'tag_id'


# In[4]:


import logging

logging.basicConfig(filename=os.path.join(data_path,logging_file), 
                    filemode='w', 
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    level=logging_level)
#logging.info('message')


# In[5]:


import os
import re
import numpy as np
import pandas as pd
from unicodedata import normalize 
import sys


# In[6]:


import stanza
if stanza_download:
    stanza.download(stanza_model_lang)

# IF NEEDED define 'pos_batch_size': 10000 in the next cell, config options.
config = {
        'processors': 'tokenize,mwt,pos,lemma',
        'lang': stanza_model_lang
         }
#not using depparse
nlp = stanza.Pipeline(**config) 


# In[7]:


import tqdm
from tqdm.notebook import tqdm_notebook
tqdm_notebook.pandas()
# to use tqdm in pandas use progress_apply instead of apply


# In[8]:


import nltk
if nltk_download:
    nltk.download('stopwords')
    nltk.download('punkt')

from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.tokenize import word_tokenize, sent_tokenize


# In[9]:


import gensim
from gensim.models.phrases import Phrases, Phraser


# In[10]:


from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import NMF


# In[ ]:





# In[ ]:





# # Read the proposals and join the content to use in the topic modelling

# In[ ]:


check_file(os.path.join(data_path,inputjsonfile))
proposals_input_df = pd.read_json(os.path.join(data_path,inputjsonfile),orient="records")
proposals_input_df = proposals_input_df[[col_id]+cols_content]


# In[ ]:


# TERMINATE THE SCRIPT IF THERE ARE NO PROPOSALS
if len(proposals_input_df) == 0:
    logging.info('No Proposals found.')
    with open(os.path.join(data_path,taggings_filename), 'w') as file:
        file.write('[]')
    with open(os.path.join(data_path,tags_filename), 'w') as file:
        file.write('[]')
    with open(os.path.join(data_path,related_props_filename), 'w') as file:
        file.write('[]')
    os._exit(0)


# In[11]:


# Normalise characters
for col in cols_content:
    proposals_input_df[col] = proposals_input_df[col].apply(lambda x: normalize('NFKC',x))
    
proposals_input_df['joined_content'] = proposals_input_df[cols_content].agg('\n'.join, axis=1)
proposals_input_df = proposals_input_df.drop(columns=list(set(cols_content)-{col_title}))


# In[ ]:





# # Lemmatise the content

# In[12]:


proposals_input_df['joined_content_topicmodelling'] = proposals_input_df['joined_content']


# In[13]:


# Using Stanza from Stanford NLP group
def content_processing_for_topicmodelling_1(txt):
    
    # Delete html tags and urls
    tmp_txt = re.sub("<[^<]+?>","",txt)
    tmp_txt = re.sub(r"http[^\s]+?\s","",tmp_txt)
    tmp_txt = re.sub(r"http[^\s]+?$","",tmp_txt)
    tmp_txt = re.sub(r"www[^\s]+?\s","",tmp_txt)
    tmp_txt = re.sub(r"www[^\s]+?$","",tmp_txt)
    
    # Tokenise, lemmatise and select only the nouns
    new_txt_tok = []
    if len(re.sub(r"[^a-zA-ZäÄëËïÏöÖüÜáéíóúáéíóúÁÉÍÓÚÂÊÎÔÛâêîôûàèìòùÀÈÌÒÙñÑ]","",tmp_txt).rstrip("\n")) != 0:
        tmp_txt_nlp = nlp(tmp_txt)
        
        for sent in tmp_txt_nlp.sentences:
            for token in sent.words:
                if noun_lemmatisation:
                    if token.upos == 'NOUN':
                        new_txt_tok.append(token.lemma)
                else:
                    new_txt_tok.append(token.text)
        
    return new_txt_tok


# In[14]:


if tqdm_notebook:
    proposals_input_df['joined_content_topicmodelling'] = proposals_input_df[
        'joined_content_topicmodelling'].progress_apply(content_processing_for_topicmodelling_1)
else:
    proposals_input_df['joined_content_topicmodelling'] = proposals_input_df[
        'joined_content_topicmodelling'].apply(content_processing_for_topicmodelling_1)


# In[ ]:





#  

# # Clean the data

# In[16]:


# Includes some extra steps for Spanish
# List of stop words to be removed
stop_words = set(stopwords.words(stopwords_lang))

if stopwords_lang == 'spanish':
    for word in stop_words:
        stop_words = stop_words.union({re.sub(r"á","a",word)})
        stop_words = stop_words.union({re.sub(r"é","e",word)})
        stop_words = stop_words.union({re.sub(r"í","i",word)})
        stop_words = stop_words.union({re.sub(r"ó","o",word)})
        stop_words = stop_words.union({re.sub(r"ú","u",word)})
    
# additional terms removed when found as an independent character
if stopwords_lang == 'spanish':
    additional_stop_words = {'(',')',',','.','...','?','¿','!','¡',':',';','d','q','u'}
else:
    additional_stop_words = {'(',')',',','.','...','?','¿','!','¡',':',';'}
all_stop_words = stop_words.union(additional_stop_words)


# In[17]:


def content_processing_for_topicmodelling_2(txt_tok):    
    new_text_tok = []
    for word in txt_tok:
        new_word = word.lower()
        new_word = re.sub(r"[^a-zA-ZäÄëËïÏöÖüÜáéíóúáéíóúÁÉÍÓÚÂÊÎÔÛâêîôûàèìòùÀÈÌÒÙñÑ\s]","",new_word)
        new_word = re.sub(r"[0-9]+","",new_word)
        new_word = new_word.rstrip("\n")
        if (len(new_word) != 0) and (new_word not in all_stop_words):
            new_text_tok.append(new_word)
        
    return new_text_tok


# In[18]:


proposals_input_df['joined_content_topicmodelling'] = proposals_input_df[
    'joined_content_topicmodelling'].apply(content_processing_for_topicmodelling_2)


# In[ ]:





# # Detect n-grams

# In[19]:


txt_unigram = proposals_input_df['joined_content_topicmodelling'].tolist()

phrases_bigrams = Phrases(txt_unigram, min_count=n_gram_min_count)
txt_bigram = [phrases_bigrams[txt] for txt in txt_unigram]
txt_bigram_joined = [' '.join(txt) for txt in txt_bigram]
    
# may contain also cuadrigrams when joining 2 bigrams:
# phrases_trigrams = Phrases(txt_bigram, min_count=n_gram_min_count)
# txt_trigram = [phrases_trigrams[txt] for txt in txt_bigram]
# txt_trigram_joined = [' '.join(txt) for txt in txt_trigram]

proposals_input_df['joined_content_topicmodelling'] = txt_bigram_joined
# proposals_input_df['joined_content_topicmodelling'] = txt_trigram_joined


# In[ ]:





# In[ ]:





# # Topic modelling (NMF)

# In[20]:


df_col_to_use = proposals_input_df['joined_content_topicmodelling']

# NUMBER OF TOPICS
n_components = numb_topics
# SELECT the TOP n_top_words WORDS for each topic
n_top_words = numb_topkeywords_pertopic

# Use tf-idf features for NMF
tfidf_vectorizer = TfidfVectorizer(max_df=max_df_val, min_df=min_df_val,
                                   max_features=n_features)
                                   
tfidf = tfidf_vectorizer.fit_transform(df_col_to_use.tolist())


# In[21]:


# Includes some extra steps for Spanish
def cleaning_features(top_features):
    clean_features = top_features.copy()
    for feature in clean_features:
        if feature+'s' in clean_features: clean_features[max(
            clean_features.index(feature),clean_features.index(feature+'s'))] = ''
            
    if stopwords_lang == 'spanish':
        for feature in clean_features:
            if feature+'es' in clean_features: clean_features[max(
                clean_features.index(feature),clean_features.index(feature+'es'))] = ''
        for feature in clean_features:
            if feature+'r' in clean_features: clean_features[max(
                clean_features.index(feature),clean_features.index(feature+'r'))] = ''       
    
    nosign_features = clean_features.copy()
    
    if stopwords_lang == 'spanish':
        for pos,fet in enumerate(nosign_features):
            nosign_features[pos]=re.sub(r"á","a",fet)
        for pos,fet in enumerate(nosign_features):
            nosign_features[pos]=re.sub(r"é","e",fet)
        for pos,fet in enumerate(nosign_features):
            nosign_features[pos]=re.sub(r"í","i",fet)
        for pos,fet in enumerate(nosign_features):
            nosign_features[pos]=re.sub(r"ó","o",fet)
        for pos,fet in enumerate(nosign_features):
            nosign_features[pos]=re.sub(r"ú","u",fet)  
        
    for pos,fet in enumerate(nosign_features):
        if fet in nosign_features[pos+1:]:
            clean_features[max(pos_2 for pos_2,fet_2 in enumerate(nosign_features) if fet_2 == fet)] = ''

    return clean_features       


# Fit the NMF model
nmf = NMF(n_components=n_components, random_state=1,
          alpha=.1, l1_ratio=.5, init='nndsvd').fit(tfidf)

# nmf.components_ is the H matrix 
# W = nmf.fit_transform(tfidf)

tfidf_feature_names = tfidf_vectorizer.get_feature_names()

# Size of the vocabulary and the nmf matrix
#print(len(tfidf_vectorizer.vocabulary_))
#print(len(tfidf_feature_names))
#nmf.components_.shape


# In[ ]:





# ### Create file: Repr_Prop. Most representative proposal for each topic

# In[22]:


W = nmf.fit_transform(tfidf)
#print(W.shape)

repr_prop_df = pd.DataFrame(columns=repr_prop_cols)

for topic_index in range(n_components):
    top_indices = np.argsort( W[:,topic_index] )[::-1]
    top_represent_proposals = []
    for proposal_index in top_indices[0:n_top_represent_props]:
        top_represent_proposals.append(proposal_index)
    
    for prop_internal_index in top_represent_proposals:
        row = [topic_index,
              proposals_input_df.loc[int(prop_internal_index),'id'],
              proposals_input_df.loc[int(prop_internal_index),'title']]
        repr_prop_df = repr_prop_df.append(dict(zip(repr_prop_cols,row)), ignore_index=True)


# In[23]:


repr_prop_df.to_json(os.path.join(data_path,repr_prop_filename),orient="records", force_ascii=False)
repr_prop_df.to_csv(os.path.join(data_path,repr_prop_filename_csv), index=False)


# In[ ]:





# ### Create file: Topics_Tags. List of Topics with their top Tags

# In[24]:


topics_tags_df = pd.DataFrame(columns=['id']+tag_cols)

# nmf.components_ is the H matrix 

for topic_idx, topic in enumerate(nmf.components_):
    obj_temp = [tfidf_vectorizer.get_feature_names()[i] for i in topic.argsort()[:-n_top_words - 1:-1]]
    clean_obj_temp = cleaning_features(obj_temp)
    clean_obj_temp.insert(0, str(topic_idx))
    #print(clean_obj_temp)
    topics_tags_df = topics_tags_df.append(dict(zip(['id']+tag_cols,clean_obj_temp)), ignore_index=True)


# In[25]:


topics_tags_df.to_json(os.path.join(data_path,topics_tags_filename),orient="records", force_ascii=False)
topics_tags_df.to_csv(os.path.join(data_path,topics_tags_filename_csv), index=False)


# In[ ]:





# ### Create file: Taggings. Each line is a Tag associated to a Proposal

# In[26]:


# Coefficients for following calculation
tag_coefs_cols = ['tag'+str(num) for num in range(1,numb_topkeywords_pertopic+1)]
topics_tags_coefs_df = pd.DataFrame(columns=['id']+tag_coefs_cols)

# nmf.components_ is the H matrix 

for topic_idx, topic in enumerate(nmf.components_):
    topics_tags_coefs_temp = []
    topics_tags_coefs_temp.append(int(topic_idx))
    for i in topic.argsort()[:-n_top_words - 1:-1]:
        topics_tags_coefs_temp.append(topic[i])
    topics_tags_coefs_df = topics_tags_coefs_df.append(dict(zip(['id']+tag_coefs_cols,
                                                                topics_tags_coefs_temp)), ignore_index=True)

for col in tag_cols:
    for topic_idx,topic in enumerate(topics_tags_df[col].tolist()):
        if topic == '':
            topics_tags_coefs_df.loc[int(topic_idx),col] = 0.0


# In[27]:


topics_tags_flat = []
for idx,topic in topics_tags_df.iterrows():
    topics_tags_flat = topics_tags_flat + topics_tags_df.loc[idx,tag_cols].tolist()
    
topics_tags_coefs_flat = []
for idx,topic in topics_tags_coefs_df.iterrows():
    topics_tags_coefs_flat = topics_tags_coefs_flat + topics_tags_coefs_df.loc[idx,tag_coefs_cols].tolist()


# In[28]:


taggings_file_df = pd.DataFrame(columns=taggings_file_cols)

for prop_idx,prop in tqdm.tqdm(enumerate(W),total=len(W)):
    proposal_topics_temp = np.zeros((len(topics_tags_flat)))
    cont = 0
    for weight in prop:
        for n in range(n_top_words):
            proposal_topics_temp[cont] = weight
            cont += 1

    proposal_tags_temp = proposal_topics_temp*topics_tags_coefs_flat
    
    # Adding the coefficients of same tags:
    for numterm_a,term_a in enumerate(topics_tags_flat):
        for numterm_b in reversed(range(numterm_a+1,len(topics_tags_flat))):
            term_b = topics_tags_flat[numterm_b]
            if (term_a == term_b):                
                proposal_tags_temp[numterm_a] = proposal_tags_temp[numterm_a] + proposal_tags_temp[numterm_b]
                proposal_tags_temp[numterm_b] = 0   
    
    for i in proposal_tags_temp.argsort()[:-n_top_words - 1:-1]:
        row = [i,proposals_input_df.loc[prop_idx,'id'],'Proposal']        
        taggings_file_df = taggings_file_df.append(dict(zip(taggings_file_cols,row)), ignore_index=True)


# ### Create file: Tags. List of Tags with the number of times they have been used

# In[29]:


tags_file_df = pd.DataFrame(columns=tags_file_cols)

for tag_id,tag in enumerate(topics_tags_flat):
    row = [tag_id,tag,0,'']
    tags_file_df = tags_file_df.append(dict(zip(tags_file_cols,row)), ignore_index=True)
    
for tag_id in taggings_file_df[taggings_file_cols_id].tolist():
    tags_file_df.loc[tag_id,tags_file_cols_count] = tags_file_df.loc[tag_id,tags_file_cols_count]+1


# ### Deleting duplicate tags from files Tag and Taggings before saving them

# In[30]:


change_rows = []
repeated_ids = []
for idx1,row1 in tags_file_df.iterrows():
    for idx2,row2 in tags_file_df.iterrows():
        if (idx2 > idx1) and (idx2 not in repeated_ids) and (row1['name'] == row2['name']):
            change_rows.append((idx1,idx2))
            repeated_ids.append(idx2)
            
tags_file_df = tags_file_df.drop(repeated_ids)


# In[31]:


for c_row in change_rows:
    taggings_file_df['tag_id'] = taggings_file_df['tag_id'].apply(lambda x: c_row[0] if x == c_row[1] else x)


# In[32]:


tags_file_df.to_json(os.path.join(data_path,tags_filename),orient="records", force_ascii=False)
tags_file_df.to_csv(os.path.join(data_path,tags_filename_csv), index=False)


# In[33]:


taggings_file_df.to_json(os.path.join(data_path,taggings_filename),orient="records", force_ascii=False)
taggings_file_df.to_csv(os.path.join(data_path,taggings_filename_csv), index=False)


# In[ ]:





# In[47]:


# proposals_input_df


# In[48]:


# repr_prop_df


# In[49]:


# topics_tags_df


# In[50]:


# taggings_file_df


# In[51]:


# tags_file_df


# In[ ]:





# # LIST OF RELATED PROPOSALS

# In[34]:


proposal_topics_coefs_cols = ['id','topic_coefs']
proposal_topics_coefs_df = pd.DataFrame(columns=proposal_topics_coefs_cols)

for prop_idx,prop in enumerate(W):
    row = [proposals_input_df.loc[prop_idx,'id'],prop.copy()]
    proposal_topics_coefs_df = proposal_topics_coefs_df.append(dict(zip(proposal_topics_coefs_cols,row)),
                                                               ignore_index=True)


# In[35]:


related_props_df = pd.DataFrame(columns=related_props_cols)

for idx,row in tqdm.tqdm(proposal_topics_coefs_df.iterrows(),total=len(proposal_topics_coefs_df)):
    prop_related_temp = []
    prop_related_temp.append(int(row['id']))
    vectora = row['topic_coefs']
    distances = [np.linalg.norm(vectora-vectorb) for vectorb in proposal_topics_coefs_df['topic_coefs'].tolist()]

    # the vector contains also the id of the initial proposal, thus numb_related_proposals+1
    for i in np.array(distances).argsort()[0:numb_related_proposals+1]:
        if distances[i] != 0.0:
            prop_related_temp.append(int(proposals_input_df.loc[i,'id']))
        
    # in case there are less related proposals than the max number
    while len(prop_related_temp) < numb_related_proposals+1:
        prop_related_temp.append('')
    
    related_props_df = related_props_df.append(dict(zip(related_props_cols,prop_related_temp)), ignore_index=True)


# In[36]:


related_props_df.to_json(os.path.join(data_path,related_props_filename),orient="records", force_ascii=False)
related_props_df.to_csv(os.path.join(data_path,related_props_filename_csv), index=False)


# In[ ]:





# In[45]:


#proposal_topics_coefs_df


# In[46]:


#related_props_df


# In[44]:


logging.info('Script executed correctly.')


# In[ ]:




