#awk -F '>' '/^>/ {F=sprintf("%s.fasta", $2); print > F;next;} {print F; close(F)}' < data/taxid_1118_complete_08_04_2020.nucleotide.rename.QC.dedup.filter.noambig.fasta

cat data/taxid_1118_complete_08_04_2020.nucleotide.rename.QC.dedup.filter.noambig.fasta | awk '{
        if (substr($0, 1, 1)==">") {filename=(substr($0,2) ".fa")}
        print $0 > filename
}'
