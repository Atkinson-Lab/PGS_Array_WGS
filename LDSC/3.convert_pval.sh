#!/usr/bin/bash


# convert neglog10_pval
input_files=("rsID_Asthma_filtered.tsv" "rsID_Breast_Cancer_filtered.tsv" "rsID_Colorectal_Cancer_filtered.tsv" 
             "rsID_DBP_filtered.tsv" "rsID_HDL_filtered.tsv" "rsID_Height_filtered.tsv" 
             "rsID_leukocyte_filtered.tsv" "rsID_RBC_filtered.tsv" "rsID_T2D_filtered.tsv" 
             "rsID_TC_filtered.tsv")

# Loop over each file
for input_file in "${input_files[@]}"; do
    # Define output file based on input file
    output_file="p_${input_file}"

    # Apply the awk command to each file
    awk -F'\t' 'BEGIN {OFS="\t"} NR==1 {print $0, "pval"} NR > 1 {print $0, 10^(-$6)}' "$input_file" > "$output_file"

    # Optionally, print the file being processed
    echo "Processed $input_file -> $output_file"
done
