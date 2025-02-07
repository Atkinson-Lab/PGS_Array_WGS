#!/bin/bash

# Base directory where your data is stored
BASE_DIR="."
OUT_DIR="."

# Output file for the combined matrix
FINAL_OUTPUT="$OUT_DIR/combined_ld_snps"

# Temporary file to store intermediate results
TEMP_FILE="$OUT_DIR/temp_combined"

# Initialize final output file
> "$FINAL_OUTPUT"  # Truncate or create an empty file

echo "Combining LD blocks for all chromosomes..."

# Loop through chromosomes 1 to 22
for chrom in {1..22}; do
    echo "Processing chromosome $chrom..."
    CHROM_DIR="$BASE_DIR/chr$chrom"
    
    # Check if the chromosome directory exists
    if [[ -d "$CHROM_DIR" ]]; then
        > "$TEMP_FILE"  # Truncate or create a temporary file for this chromosome
        
       # Loop through block files in the chromosome directory
       for blk_file in $(ls "$CHROM_DIR"/blk_* | sort -V); do
           if [[ -f "$blk_file" ]]; then
               echo "Processing $blk_file"  # Debug: Print the file being processed
               # Append block data to the temporary file
               cat "$blk_file" >> "$TEMP_FILE"
           else
               echo "No block files found in $CHROM_DIR"
           fi
       done
        
        # Append chromosome data to the final output
        if [[ -s "$TEMP_FILE" ]]; then
            cat "$TEMP_FILE" >> "$FINAL_OUTPUT"
            echo "Chromosome $chrom combined and added to final output."
        else
            echo "No data found for chromosome $chrom."
        fi
    else
        echo "Chromosome directory $CHROM_DIR does not exist."
    fi
done

# Clean up temporary file
rm -f "$TEMP_FILE"

echo "All chromosomes combined. Final output saved to $FINAL_OUTPUT."
