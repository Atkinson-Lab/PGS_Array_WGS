#!/bin/bash

# Define file prefixes
prefixes=("Array" "WGS")

# Loop over each prefix
for prefix in "${prefixes[@]}"; do
    # Paths to input and output files
    input_gz="data/${prefix}_Vars_QCed_dbsnp.tsv.bgz"
    input_file="data/${prefix}_Vars_QCed_dbsnp.tsv"
    output_file="bim/${prefix}_Vars_QCed_dbsnp.bim"

    # Rename and decompress the file
    if [[ -f "$input_gz" ]]; then
        mv "$input_gz" "${input_gz/.bgz/.gz}"
        gunzip "${input_gz/.bgz/.gz}"
        echo "Decompressed $input_gz to $input_file"
    else
        echo "Input file $input_gz not found for prefix: $prefix!"
        continue
    fi

    # Process the decompressed TSV file
    if [[ -f "$input_file" ]]; then
        # Use awk to process and remove rows with NA values
        awk '
        BEGIN { FS="\t"; OFS="\t" }
        NR > 1 {
            # Check if any field contains "NA", if so skip the row
            skip = 0
            for (i = 1; i <= NF; i++) {
                if ($i == "NA") {
                    skip = 1
                    break
                }
            }
            # If no "NA" found, process the row
            if (skip == 0) {
                split($1, locus, ":");
                gsub("chr", "", locus[1]);
                print locus[1], $2, 0, locus[2], $4, $3
            }
        }' "$input_file" > "$output_file"
        echo "Reformatted file saved to $output_file for prefix: $prefix"
    else
        echo "Decompressed file $input_file not found for prefix: $prefix!"
        continue
    fi
done
