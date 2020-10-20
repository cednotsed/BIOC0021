workdir=data/
for i in data/split_fastas/*
do
    genome_name=$(basename $i | cut -d '.' -f 1)

    prokka --kingdom viruses \
        --outdir $(echo $i | sed 's/\.fa/\.prokka.out/') \
        --prefix anellovirus_$genome_name \
        --metagenome \
        $i
done

# Merge all gff files into single folder
mkdir ${workdir}/gff_files
cp ${workdir}/*.prokka.out/*.gff ${workdir}/gff_files

roary -f roary_out -e -n -v ${workdir}/gff_files/*.gff
