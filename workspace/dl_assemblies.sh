# Use NCBI datasets API (see https://www.ncbi.nlm.nih.gov/datasets/docs/command-line-start/)
#datasets download genome taxon "anellovirus"
#mv ncbi_dataset.zip phylogeny_building/data/
cd phylogeny_building/data
#unzip ncbi_dataset.zip
#rm ncbi_dataset.zip
#mv ncbi_dataset/data/* ncbi_dataset
#rm -r ncbi_dataset/data
cd ncbi_dataset/
mv */*.fna ./
rm -R `ls -1 -d */`

