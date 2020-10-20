rm(list = ls())
require(Biostrings)
require(stringr)
setwd("~/git_repos/BIOC0021/workspace/phylogeny_building/")
dna <- readDNAStringSet("data/anellovirus_368.fasta")

# Average length of genome
l <- mean(width(dna))

# Probability of observing a k-mer by chance
q <- 0.0001

# no. of letters in alphabet
n_alphabet <- 4

# Calculate k value for mash
k <- ceiling(log(l * (1 - q)/ q, base = n_alphabet))
print(k)



