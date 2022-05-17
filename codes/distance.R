#!/usr/bin/RScript
####################################################
# Author: Vi Dam
# Version: 20201218
# Goal: Calculate the distance between artiles using article terms and meshTerms. Then, compare the difference between two methods.
#
# The distance between artiles are calculated using Euclidean distance, angle distance and SVD distance
# The distance among articles’ mesh terms is also calculated using cosine angle distance.
#
# “tdMatrix.txt” and “meshMatrix.txt” file will be used as inputs.
# Then, the difference between
# 1. articles’ cosine angle and mesh-term’s distance,
# 2. articles’ SVD cosine angle and mesh-term’s distance
# are calculated.
#
# Usage: Rscript distance.R path/meshMatrix.txt path/tdMatrix.txt
####################################################
args = commandArgs(trailingOnly=TRUE)

# test if there is at least 2 argument: if not, return an error
if (length(args)==0 | length(args)==1) {
  stop("At least two argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==2) {
  # default output file
  #args[3] = "out.txt"
}

#------------- READ FILES-------------------------------------------------------
mesh <- read.table("outfiles/meshMatrix.txt", header=T, check.names=F, sep="\t", quote="")
#mesh <- read.table(args[1], header=T, check.names=F, sep="\t", quote="")
mesh <- mesh[,which(colSums(mesh)>0)]

D <- read.table("outfiles/tdMatrix.txt", header=T, check.names=F, sep="\t", quote="")
#D <- read.table(args[2], header=T, check.names=F, sep="\t", quote="")
ind <- match(colnames(mesh), colnames(D))
D <- D[,ind]

#------------- TERM-DOCUMENT MATRIX Distance calculation------------------------
# ----- Euclidean distance ----------
tD <- t(D)
#print(tD)

dist <- as.matrix(dist(tD, method="euclidean"))
#print(colnames(dist))
D.dist <- t(combn(colnames(dist), 2))
D.dist <- data.frame(D.dist, euclDist=dist[D.dist])
#print(D.dist)

# ----- cosine angle distances-------
D.dist$acos <- ""
for (i in 1:nrow(D.dist)){
  D.dist$acos[i] <- acos((tD[rownames(tD)==D.dist[i,1],] %*% tD[rownames(tD)==D.dist[i,2],]) / (norm(tD[rownames(tD)==D.dist[i,1],], "2") * norm(tD[rownames(tD)==D.dist[i,2],], "2")))
}

# ----- SVD distance-----------------
D2 <- as.matrix(D)
colnames(D2) <- NULL

D.svd <- svd(D2)
S <- diag(D.svd$d)

# ----- Low rank approximation-------
n <- 36
DLowRank <- D.svd$u[,1:n] %*% S[1:n,1:n] %*% t(D.svd$v [ ,1:n])

tDLowRank <- t(DLowRank)
rownames(tDLowRank) <- rownames(tD)

# ----- Distance between low rank articles and query-----
D.dist$SVDLowRank <- ""
for (i in 1:nrow(D.dist)){
  D.dist$SVDLowRank[i] <- acos((tDLowRank[rownames(tDLowRank)==D.dist[i,1],] %*% tDLowRank[rownames(tDLowRank)==D.dist[i,2],]) / (norm(tDLowRank[rownames(tDLowRank)==D.dist[i,1],], "2") * norm(tDLowRank[rownames(tDLowRank)==D.dist[i,2],], "2")))
}

D.dist[,3:5] <- apply(D.dist[,3:5], 2, as.numeric)
write.table(D.dist, file="outfiles/TermsDistance.tsv", quote=F, sep="\t", row.names=F)

# ------------VALIDATE using MESH-TERMS MATRIX----------------------

# ------ VSM Euclidean distance------
tmesh <- t(mesh)
dist <- as.matrix(dist(tmesh, method="euclidean"))
mesh.dist <- t(combn(colnames(dist), 2))
mesh.dist <- data.frame(mesh.dist, VSM=dist[mesh.dist])
mesh.dist["euclDist"] <- mesh.dist["VSM"]

# ------ angle distances--------
mesh.dist$acos <- ""
for (i in 1:nrow(mesh.dist)){
  mesh.dist$acos[i] <- acos((tmesh[rownames(tmesh)==mesh.dist[i,1],] %*% tmesh[rownames(tmesh)==mesh.dist[i,2],]) / (norm(tmesh[rownames(tmesh)==mesh.dist[i,1],], "2") * norm(tmesh[rownames(tmesh)==mesh.dist[i,2],], "2")))
}
mesh.dist[,3:ncol(mesh.dist)] <- apply(mesh.dist[,3:ncol(mesh.dist)], 2, as.numeric)
write.table(mesh.dist, file="outfiles/meshDistance.tsv", quote=F, sep="\t", row.names=F)

# ------ DIFFERENCES between cosine angle and DLowRank------
tmp <- norm(as.matrix(mesh.dist$euclDist) - as.matrix(D.dist$euclDist), "F") / norm(as.matrix(D.dist$euclDist), "F") * 100
print(paste("The distance between articles terms and mesh terms using Euclidean distance is", tmp, "percent."))

tmp <- norm(as.matrix(mesh.dist$acos) - as.matrix(D.dist$acos), "F") / norm(as.matrix(D.dist$acos), "F") * 100
print(paste("The distance between articles terms and mesh terms using cosine angle is", tmp, "percent."))

tmp <- norm(as.matrix(mesh.dist$acos) - as.matrix(D.dist$SVDLowRank), "F") / norm(as.matrix(D.dist$SVDLowRank), "F") * 100
print(paste("The distance between articles terms and mesh terms using SVD is", tmp, "percent."))
