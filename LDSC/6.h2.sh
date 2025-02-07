#!/bin/bash

while read -r pheno; do
    # Skip empty lines or lines starting with a comment
    if [[ -z "$pheno" || "$pheno" =~ ^# ]]; then
        continue
    fi

    # Print the current phenotype being processed (optional)
    echo "Running ldsc for phenotype: $pheno"

    # Run the ldsc.py command
    ldsc/ldsc.py \
        --h2 "${pheno}.sumstats.gz" \
        --ref-ld-chr eur_w_ld_chr/ \
        --w-ld-chr eur_w_ld_chr/ \
        --out "h2_${pheno}"

    # Check if ldsc.py ran successfully
    if [[ $? -eq 0 ]]; then
        echo "Successfully processed $pheno"
    else
        echo "Error processing $pheno"
    fi
done < <(awk '{print $1}' phenotype_list.txt)  
