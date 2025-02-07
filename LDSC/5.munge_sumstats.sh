#!/bin/bash

# Read phenotype names and corresponding N values from phenotype_list.txt
while read -r pheno N; do
    # Skip empty lines or lines starting with a comment
    if [[ -z "$pheno" || "$pheno" =~ ^# ]]; then
        continue
    fi

    echo "Processing phenotype: '$pheno' with sample size N=$N"

    # Run the munge_sumstats.py command with the appropriate arguments
    ldsc/munge_sumstats.py \
        --sumstats "re_p_rsID_${pheno}_filtered.tsv" \
        --N "$N" \
        --out "${pheno}" \
        --merge-alleles "w_hm3.snplist"

    # Check if munge_sumstats.py ran successfully
    if [[ $? -eq 0 ]]; then
        echo "Processed $pheno successfully with N=$N"
    else
        echo "Error processing $pheno"
    fi
done < phenotype_list.txt  # Loop through each line in phenotype_list.txt

