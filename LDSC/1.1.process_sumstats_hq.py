import os
import pandas as pd

# Define input and output directories
input_dir = "LDSC/ukbb" 
output_dir = "LDSC/ukbb"

# List of input files to process
input_files = [
    "Height.tsv",
    "DBP.tsv",
    "HDL.tsv",
    "TC.tsv",
    "RBC.tsv",
    "leukocyte.tsv",
    "T2D.tsv",
    "Asthma.tsv",
    "Breast_Cancer.tsv",
    "Colorectal_Cancer.tsv"
]

# Columns to keep
columns_to_keep = ['chr', 'pos', 'ref', 'alt', 'beta_meta_hq', 'neglog10_pval_meta_hq']

# Function to process each file
def process_file(input_file):
    print(f"Processing {input_file}...")

    # Construct the full file path for the input file
    file_path = os.path.join(input_dir, input_file)

    # Generate the output file path
    output_file = os.path.join(output_dir, os.path.basename(input_file).replace(".tsv", "_filtered.tsv"))
    
    # Use a flag to check if the file has been processed
    is_first_chunk = True

    # Process the file in chunks
    try:
        for chunk in pd.read_csv(file_path, sep='\t', dtype=str, chunksize=1000000):  # Read in chunks of 1 million rows
            # Check if the necessary columns exist in the chunk
            missing_columns = [col for col in columns_to_keep if col not in chunk.columns]
            if missing_columns:
                print(f"Warning: The following columns were not found in {file_path}: {', '.join(missing_columns)}")

            # Filter the DataFrame to only keep the specified columns
            df_filtered = chunk[columns_to_keep]

            # If it's the first chunk, write the header; otherwise, append without header
            if is_first_chunk:
                df_filtered.to_csv(output_file, sep='\t', index=False, mode='w', header=True)
                is_first_chunk = False
            else:
                df_filtered.to_csv(output_file, sep='\t', index=False, mode='a', header=False)
        
        print(f"Saved filtered data to {output_file}")

    except Exception as e:
        print(f"Error processing {file_path}: {e}")

# Loop through all the input files and process them
for input_file in input_files:
    process_file(input_file)

print("Processing complete for all files.")
