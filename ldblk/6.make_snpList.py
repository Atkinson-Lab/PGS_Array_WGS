import pandas as pd
import argparse
import os

# Function to process each chromosome
def process_chromosome(chromosome):
    # Input file path (adjust this to your actual file path)
    input_file = "./data/eur/qc/hgdp1kgp_qc_chr{}.eur_snpList.txt".format(chromosome)

    # Define the column names
    column_names = ['CHROM', 'POS', 'ID', 'REF', 'ALT']

    # Open the reference file containing LD blocks (adjust the path if needed)
    reference_file = "./pyrho_EUR_LD_blocks.txt"
    blocks = []

    # Read the reference file and build a list of blocks for quick lookup
    with open(reference_file, 'r') as ref_file:
        for line in ref_file:
            if line.strip() and not line.startswith('#'):
                parts = line.split()
                ref_chr = parts[3]  # Chromosome (formatted as 'chr1', 'chr2', etc.)
                ref_start = int(parts[1])  # Start position (ensure it's an integer)
                ref_end = int(parts[2])  # End position (ensure it's an integer)
                ref_blk = parts[4]  # Block identifier

                # Only store blocks that match the current chromosome (using 'chr{chromosome}' format)
                if ref_chr == '{}'.format(chromosome):  # Ensure ref_chr is in the format 'chr{chromosome}'
                    blocks.append((ref_blk, ref_start, ref_end))  # Store tuple with block name, start and end positions

    # Ensure the output directory for the chromosome exists
    output_dir = "chr{}".format(chromosome)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Read the entire input file and filter by chromosome
    dtype_dict = {'CHROM': str, 'POS': int, 'ID': str, 'REF': str, 'ALT': str}
    snp_df = pd.read_csv(input_file, delim_whitespace=True, header=None, names=column_names, low_memory=False)
    snp_df = snp_df[snp_df['CHROM'] == '{}'.format(chromosome)]  # Ensure input CHROM is in the format 'chr{chromosome}'

    # Dictionary to store SNPs for each block (to write them all at once later)
    block_snps = {block[0]: [] for block in blocks}  # Initialize empty lists for each block

    # Process each row in the dataframe
    for _, row in snp_df.iterrows():
        input_pos = int(row['POS'])  # Ensure input_pos is an integer
        input_id = row['ID']
        input_chr = row['CHROM']  # This will be 'chr{chromosome}'

        # Check if the SNP's chromosome is the same as the reference chromosome
        if input_chr == '{}'.format(chromosome):
            # Check each block to see if the position falls within the block range
            for block, start_pos, end_pos in blocks:
                if start_pos < input_pos < end_pos:  # Ensure the position is within the block range
                    block_snps[block].append(input_id)  # Store SNP ID for the block

    # Write the SNPs to files for each block (in the same order as in reference file)
    for block, snps in block_snps.items():
        if snps:  # Only write to file if there are SNPs
            output_file = os.path.join(output_dir, "{}".format(block))
            with open(output_file, 'w') as f:
                f.write("\n".join(snps) + "\n")  # Write all SNPs to the file at once

    print("Processed {} rows for chromosome {}".format(len(snp_df), chromosome))

# Main function to parse arguments and run the script
def main():
    # Create an argument parser to allow passing of the chromosome
    parser = argparse.ArgumentParser(description="Process SNP list and match against reference blocks")

    # The chromosome argument is required and positional
    parser.add_argument('chromosome', type=int, help="Chromosome number to process")

    args = parser.parse_args()

    # Process the specified chromosome
    process_chromosome(args.chromosome)

if __name__ == "__main__":
    main()
