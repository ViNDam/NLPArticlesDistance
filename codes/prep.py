#!/usr/bin/python
#############################################
# Author: Vi Dam
# Version: 20201218
# Goal: Extract tokens and meshTerm from the input cancersArticles.txt
#
# Usage: python prep.py path/cancersArticles.txt
#############################################
import sys
import os
import pandas as pd
import scipy
import string
import argparse
import numpy as np
from numpy.linalg import norm
import nltk
from nltk import *
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
nltk.download('stopwords')
nltk.download('punkt')
nltk.download('wordnet')

# ----------------- Parse parameters  ---------------------------
parser = argparse.ArgumentParser(description='Prep data')

parser.add_argument("-f", required=True, default=True,
                    help="Articles text file")

args = parser.parse_args()

if args.f is None:
    parser.error('No action requested, add -f')
    
args = parser.parse_args()

# ----------------- Read articles file  ---------------------------
df = pd.read_csv(args.f, sep='\t')

# ----------------- Remove non-numerical Year--------
df.dropna(subset = ["Year"], inplace=True)
df['Year'] = pd.to_numeric(df['Year'], errors='coerce')
df.sort_values(by='Year', ascending=True, inplace=True)

# ----------------- Filter Year ---------------------------
# # Filter Year - from 2016------
# df.dropna(subset=['Year'])
# df.dropna(subset=['MeshTerm'])
# df2 = df.copy()
# df2 = df2[(df2.Year >= 2016)]
# df2.fillna("", inplace=True) #374864 articles, 4 cols

# Filter Year - from 2019-----
df.dropna(subset=['Year'])
df.dropna(subset=['MeshTerm'])
df2 = df.copy()
df2 = df2[(df2.Year >= 2019)]
df2.fillna("", inplace=True) #542 articles, 4 cols


#--------------------TERM-DOCUMENT MATRIX---------------------------------
tokens = []
for t in df2.Title:
    tokens.append(word_tokenize(t)) #list of all 1118214 titles/sentences'tokens)

# remove stop words, non alpha characters and words with less than 2 alphabet
# convert lemmatize, combine root words. ie. cancers & cancer = cancer & cancer
stopwords = nltk.corpus.stopwords.words('english')
lemmatizer = WordNetLemmatizer()
words = [lemmatizer.lemmatize(word) for word in words]

for ind,title in enumerate(tokens):
    #tokens[ind+1] = [w.lower() for w in title if w.isalpha()] #can't use, it removes anti-cancer
    title = [w.lower() for w in title if w not in string.punctuation]
    title = [w.lower() for w in title if len(w) > 2]
    title = [lemmatizer.lemmatize(w) for w in title]
    tokens[ind] = [w for w in title if w.lower() not in stopwords]

#--------list of unique tokens of all titles--------
terms = []
for ind, i in enumerate(tokens):
    #print(ind)
    for w in i:
        if w not in terms:
            terms.append(w)

#--------create term-document matrix-----------------
tdMat = np.array([[0]*len(terms)]*len(tokens))
for ind, i in enumerate(tokens):
    inds = []
    for w in i:
        inds.append(terms.index(w))
    inds.sort()
    d = {x:inds.count(x) for x in inds}
    tmp = [int(k) for k in d.keys()]
    tmp1 = [int(k) for k in d.values()]
    tdMat[ind,tmp] = tmp1

tdMat = tdMat.transpose()
tdMat = pd.DataFrame(data=tdMat, columns=df2['PMID'], index=terms)
tdMat.to_csv("tdMatrix.txt", header=True, sep="\t",index=False)


#--------------------MESH - TERMS MATRIX----------------------------------
mTokens = []
for t in df2.MeshTerm:
    mTokens.append(word_tokenize(t))

# remove stopwords, special characters
for ind,title in enumerate(mTokens):
    title = [w.lower() for w in title if w not in string.punctuation]
    title = [lemmatizer.lemmatize(w) for w in title]
    mTokens[ind] = [w for w in title if w.lower() not in stopwords]

#-------- list of unique tokens of all mesh terms--------
mTerms = []
for ind, i in enumerate(mTokens):
    #print(ind)
    for w in i:
        if w not in mTerms:
            mTerms.append(w)

# ------ create mesh term matrix---------------
meshMat = np.array([[0]*len(mTerms)]*len(mTokens))
for ind, i in enumerate(mTokens):
    inds = []
    for w in i:
        inds.append(mTerms.index(w))
    inds.sort()
    d = {x:inds.count(x) for x in inds}
    tmp = [int(k) for k in d.keys()]
    tmp1 = [int(k) for k in d.values()]
    meshMat[ind,tmp] = tmp1

meshMat = meshMat.transpose()
meshMat = pd.DataFrame(data=meshMat, columns=df2['PMID'], index=mTerms)
meshMat.to_csv("meshMatrix.txt", header=True, sep="\t",index=False)
