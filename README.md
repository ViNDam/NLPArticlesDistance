# NLPArticlesDistance

This algorithm extracts the list of tokens from each cancer research article since 2019 and calculates the relationship between articles using algorithms including Euclidean distance, Vector Space Model (VSM), and Latent Semantic Analysis (LSA). Specifically, the Euclidean distance, the cosine angle obtained from VSM, and the Singular Vector Decomposition (SVD) low rank of LSA methods are compared. The distance between Mesh Terms of each document is calculated and used to validate the abovementioned results. 

All cancer research articles were downloaded from PubMed using the descriptor name “Neoplasms”; then they were parsed to extract the PubMed ID (PMID), Year of publication (Year), Title, and Mesh Term into the “cancersArticles.txt” file, which is the input file for this algorithm. 

## INSTALL
The user needs to install pandas, scipy, string, NumPy, and nltk packages. 


## CODE
The algorithm includes two parts:

### 1.	prep.py
In this step, the code takes “cancersArticles.txt” as input and removes all articles that contain empty information related to Year and Mesh Term. Then, it filters the articles since 2019. 
The list of all unique tokens is extracted from the articles. The stopwords, punctuations, and words less than or equal to 2 characters are removed. All the words are converted to non-capitalized words. Similar unique tokens for mesh terms are also created using the same pipeline. 
The term-document matrix and mesh-document matrix are created by counting the number of times the word appears in each article’s title or Mesh term list, respectively. “tdMatrix.txt” and “meshMatrix.txt” are produced. 

### 2.	distance. R
The “tdMatrix.txt” and “meshMatrix.txt” files will be used as inputs in this step. The distance between articles using Euclidean distance, angle distance, and top 5 SVD distance methods are calculated. The distance among articles’ mesh terms is computed using cosine angle distance. 
Then, the difference between articles’ euclidean distance, articles’ cosine angle and mesh terms distance, and articles’ SVD cosine angle with respect to mesh terms distance are calculated. 
The differences between those three distances and mesh terms distance are compared and analyzed for the project conclusion. 


## USAGE

Note: This project was tested and run on a GPU machine, and it took several hours to complete the first step, “prep.py.” 

### 1.	prep.py
In this code, a list of “stopwords,” “Punkt,” and “wordnet” will be automatically downloaded from nltk. 
The user inputs the text document containing articles with PMID, Year, Title, and MeshTerm in tab-delimited format. 

python prep.py path/cancersArticles.txt

The two output files “tdMatrix.txt” and “meshMatrix.txt” will be created in the same directory. 
The user can change the year filter in line 38.

### 2.	distance. R
The user input the path to meshMatrix then tdMatrix. 

Rscript distance.R path/meshMatrix.txt path/tdMatrix.txt

The “dist” is used, but it is supposed to be the standard in R. The user should not need to install the package unless it is not found. 
The user can change the number of selected SVD low-rank approximations in line 43. 
