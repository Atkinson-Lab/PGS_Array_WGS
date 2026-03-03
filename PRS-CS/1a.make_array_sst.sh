#!/bin/bash

# List of Array types and Phenotypes
types=("Array")
phenotypes=("Height" "DBP" "HDL" "TC" "RBC" "leukocyte" "T2D" "Asthma" "Breast_Cancer" "Colorectal_Cancer")

# Loop over Array type and Phenotypes
for type in "${types[@]}"; do
    for phenotype in "${phenotypes[@]}"; do
        # Define input and output files based on Array type and Phenotype
        input_file="data/${type}_${phenotype}_QCed_dbsnp.tsv"
        output_file="sst/${type}_${phenotype}_QCed_dbsnp.sst"

        # Check if the input file exists
        if [[ -f "$input_file" ]]; then
            # Use awk to modify the columns, calculate P, and remove rows with any NA
            awk '
            BEGIN {
                FS="\t";
                OFS="\t";
                # Print the header with the new column names
                print "SNP", "A1", "A2", "BETA", "P"
            }
            NR > 1 {
                # Initialize P to "NA" in case it is not calculated
                P = "NA";

                # Convert the value in $6 to numeric using +0
                neglog10_value = $6 + 0;  # Convert to numeric

                # Skip row if any value is "NA"
                if ($2 == "NA" || $3 == "NA" || $4 == "NA" || $5 == "NA" || $6 == "NA") {
                    next  # Skip this row if any field is "NA"
                }

                # Only calculate P if the value in $6 is numeric
                if (neglog10_value == neglog10_value) {  # Check if the value is a valid number
                    # If the value in column 6 is numeric, calculate P as 10 raised to the negative of that value
                    P = exp(-neglog10_value * log(10));  # Correct exponentiation

                    # Set P to 1e-300 if it is smaller than 1e-300
                    if (P < 1e-300) {
                        P = 1e-300;
                    }
                }

                # Assign columns to variables
                SNP = $2
                A1 = $3
                A2 = $4
                BETA = $5

                # Convert BETA and P to scientific notation
                BETA = sprintf("%.5e", BETA)
                P = sprintf("%.5e", P)

                # Only print the row if P is not "NA"
                if (P != "NA") {
                    print SNP, A1, A2, BETA, P
                }
            }' "$input_file" > "$output_file"

            echo "Reformatted file saved to $output_file"
        else
            echo "Input file $input_file not found!"
            continue  # Skip to the next iteration if file is not found
        fi
    done
done
