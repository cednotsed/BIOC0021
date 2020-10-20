rm(list = ls())
setwd("~/git_repos/BIOC0021/workspace/phylogeny_building/")
packages <- c("data.table","ape","phangorn","ggplot2","seqinr","ggtree","RColorBrewer", "reshape2")
invisible(lapply(packages, function(x) suppressPackageStartupMessages(require(x, character.only=T))))

cm <- read.csv("data/mash_matrix_k13.tsv", sep = "\t", 
               header = T,
               row.names = 1,
               stringsAsFactors = F)

cm <- data.matrix(cm)

# Build NJ tree
tree <- nj(cm)

# Get tree metadata
meta <- fread("data/anellovirus_n1147_201020.csv")
meta <- meta[, c("Accession", "bins", "Host Genus", "Genus", "Host Order")]
meta <- meta %>%
  mutate(Genus = replace(Genus, Genus == "", "Unassigned"))

# Drop tips which cannot be matched to protein accessions file
tree$tip.label <- colsplit(tree$tip.label, '\\.', c("desired", NA))$desired
tree <- drop.tip(tree, tree$tip.label[is.na(match(tree$tip.label, meta$Accession))])

# Match tips to metadata
meta.match <- meta[match(tree$tip.label, meta$Accession), ]

# Make dataframe for tree annotations
dd <- data.frame(Accession=meta.match$Accession, 
                 Genus=meta.match$Genus)

rownames(dd) <- tree$tip.label

# Plot tree
pal <- c("dodgerblue2", "#E31A1C", # red
  "green4",
  "#6A3D9A", # purple
  "#FF7F00", # orange
  "steelblue", "gold1",
  "skyblue2", "#FB9A99", # lt pink
  "palegreen2",
  "#CAB2D6", # lt purple
  "#FDBF6F", # lt orange
  "khaki2", NA,
  "maroon"
)

p <- ggtree(tree)
p <- p %<+% dd +
  geom_tippoint(aes(hjust = 0.5,
                    color = Genus), alpha = .8) +
  labs(color = "Viral Genus")  +
  scale_color_manual(values=pal) +
  theme(legend.title = element_text(size = 10),
        legend.text = element_text(size = 10))
p

ggsave("../results/anellovirus_mash_k13_NJ.png", dpi = 300, width = 5, height = 8)
