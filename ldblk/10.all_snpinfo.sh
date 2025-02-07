#!/usr/bin/bash

# Directory containing the files
DATA_DIR="ldblk/data/eur/qc"
OUTPUT_FILE="ldblk/all_snpinfo"

# Initialize the output file (overwrite if it exists)
echo -e "CHR\tSNP\tBP\tA1\tA2\tMAF" > "$OUTPUT_FILE"

# Loop through chromosomes 1 to 22
for CHR in {1..22}; do
    INPUT_FILE=${DATA_DIR}/hgdp1kgp_qc_chr${CHR}.eur_qc.maf.vcf.gz

    if [ -f "$INPUT_FILE" ]; then
        echo "Processing chromosome ${CHR}..."

        # Decompress the VCF file using zcat and extract relevant columns
        zcat "$INPUT_FILE" | awk '{
            # Skip lines starting with ## or #
            if ($0 ~ /^##/ || $0 ~ /^#/) next;

            # Extract columns for chr, snp, bp, a1, a2
            chr = $1;
            snp = $3;
            bp = $2;
            a1 = $5;
            a2 = $4;

            # Extract MAF value from the INFO field (8th column)
            # Assume MAF is in the format "MAF=0.25" in the 8th column
            split($8, info, ";");
            for (i in info) {
                if (info[i] ~ /^MAF=/) {
                    maf = substr(info[i], 5);  # Extract the value after "MAF="
                    break;
                }
            }

            # Print the required columns in tab-separated format
            print chr, snp, bp, a1, a2, maf;
        }' OFS="\t" >> "$OUTPUT_FILE"
    else
        echo "File $INPUT_FILE does not exist. Skipping..."
    fi
done

echo "Combination complete. Output saved to $OUTPUT_FILE."

