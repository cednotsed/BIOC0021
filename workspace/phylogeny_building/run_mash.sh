#fasta_file='data/anellovirus_n1143_outgroup.fasta'
#out='data/mash_matrix_k13_outgroup'
fasta_file='data/anellovirus_n1143_201020.fasta'
out='data/mash_matrix_k13_no_outgroup'

mash sketch -i $fasta_file -k 13

mash dist ${fasta_file}.msh ${fasta_file}.msh -t > ${out}.tsv