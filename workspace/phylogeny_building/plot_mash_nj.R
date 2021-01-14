rm(list = ls())
setwd("~/git_repos/BIOC0021/workspace/phylogeny_building/")
packages <- c("tidyverse", "data.table","ape","phangorn","ggplot2","seqinr","ggtree","RColorBrewer", "reshape2")
invisible(lapply(packages, function(x) suppressPackageStartupMessages(require(x, character.only=T))))

cm.no_outgroup <- read.csv("data/mash_matrix_k13_no_outgroup.tsv", sep = "\t", 
               header = T,
               row.names = 1,
               stringsAsFactors = F)

cm.no_outgroup <- data.matrix(cm.no_outgroup)

cm.outgroup <- read.csv("data/mash_matrix_k13_outgroup.tsv", sep = "\t", 
                           header = T,
                           row.names = 1,
                           stringsAsFactors = F)
cm.outgroup <- data.matrix(cm.outgroup)

# Build NJ tree
tree.no_outgroup <- nj(cm.no_outgroup)
tree.outgroup <- nj(cm.outgroup)

# Root tree with outgroup
outgroup <- "NC_001792.2"
sum(tree.outgroup$tip.label %in% c(outgroup))
tree.root <- root(tree.outgroup, outgroup, resolve.root = T)
write.tree(tree.root, "data/anelloviridae_n1143.outgroup.rooted.tree")

## OPEN FIGTREE TO VIEW ##

# Root tree without outgroup using basal tip
basal_tip <- "MK012527.1"
sum(tree.no_outgroup$tip.label %in% c(basal_tip))
final_tree <- root(tree.no_outgroup, basal_tip,resolve.root = T)

# Get tree metadata
meta <- fread("data/anellovirus_n1143_201020.csv")
meta <- meta[, c("Accession", "bins", "Host Genus", "Genus", "Host Order")]
meta <- meta %>%
  mutate(Genus = replace(Genus, Genus == "", "Unassigned"))

# Fix tip label format
final_tree$tip.label <- colsplit(final_tree$tip.label, '\\.', c("desired", NA))$desired

# Match tips to metadata
meta.match <- meta[match(final_tree$tip.label, meta$Accession), ]

# Make dataframe for tree annotations
dd <- data.frame(Accession=meta.match$Accession, 
                 Genus=meta.match$Genus)

rownames(dd) <- final_tree$tip.label

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

p <- ggtree(final_tree)
p.clean <- p %<+% dd +
  geom_tippoint(aes(hjust = 0.5,
                    color = Genus), alpha = .8) +
  labs(color = "Viral Genus")  +
  scale_color_manual(values=pal) +
  # theme(legend.title = element_text(size = 14, face = "bold"),
  #       legend.text = element_text(size = 14))
  theme(legend.position = "none")
p.clean

ggsave("../results/anellovirus_mash_k13_NJ.rooted.png", plot = p.clean, dpi = 600, width = 5, height = 8)

# Get tree with labels

p.labels <- p + geom_text(aes(label = label), size = 1, hjust=-0.3) %<+% dd +
  geom_tippoint(aes(hjust = 0.5,
                    color = Genus), alpha = .8) +
  labs(color = "Viral Genus")  +
  scale_color_manual(values = pal) +
  theme(legend.title = element_text(size = 10),
        legend.text = element_text(size = 10))
p.labels

ggsave("../results/anellovirus_mash_k13_NJ.rooted.annot.png", plot = p.labels, dpi = 100, width = 40, height = 40)

write.tree(final_tree, "data/anelloviridae_n1143.outgroup.rooted.final.tree")
