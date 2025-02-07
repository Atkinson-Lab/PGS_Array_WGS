#!/usr/bin/bash


# change column names so that munge_sumstats.py can recognize
for file in p_rsID_*_filtered.tsv; do
    awk 'BEGIN {OFS="\t"; print "pos", "chr", "A2", "A1", "BETA", "neglog10_pval", "seqnames", "strand", "SNP", "P"} 
         NR > 1 {print}' "$file" > "re_${file%.tsv}.tsv"
done
