for i in data/split_fastas/*.fa
do
    echo $i | sed 's/\.fa/\.prokka.out/'
done
