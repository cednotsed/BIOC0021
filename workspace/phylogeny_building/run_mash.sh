fasta_file='data/anellovirus_n1147_201020.fasta'
out='data/mash_matrix_k13'

mash sketch -i $fasta_file -k 13

mash dist ${fasta_file}.msh ${fasta_file}.msh -t > ${out}.tsv
