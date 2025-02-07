#!/usr/bin/python

import os
import scipy as sp
import h5py
import sys

# Function to process a single chromosome
def process_chromosome(chrom):
    # Base directory where your data is stored
    BASE_DIR = '/storage/atkinson/home/u244264/ldblk/hgdp1kg/hg38/'

    # Output directory for the HDF5 files
    OUT_DIR = '/storage/atkinson/home/u244264/ldblk/hgdp1kg/hg38/ldblk_hgdp1kg_eur_hg38/'

    print(f'... parsing chromosome {chrom} ...')

    # Define the input folder for the current chromosome
    chrom_folder = os.path.join(BASE_DIR, f'chr{chrom}')

    # Define the output HDF5 file name
    chr_name = os.path.join(OUT_DIR, f'ldblk_hgdp1kg_chr{chrom}.hdf5')

    # Open HDF5 file for writing
    with h5py.File(chr_name, 'w') as hdf_chr:
        blk_cnt = 0

        # List all files in the chromosome folder and filter out non-LD block files
        blk_files = [f for f in os.listdir(chrom_folder) if f.startswith('ldblk') and f.endswith('.ld')]

        # Sort block files numerically based on block index (e.g., "ldblk1.ld" -> 1, "ldblk10.ld" -> 10)
        blk_files.sort(key=lambda x: int(x.split('ldblk')[1].split('.ld')[0]))

        # Iterate through the sorted list of block files
        for blk_file in blk_files:
            # Extract block index (e.g., "ldblk1.ld" -> block 1)
            blk_index = blk_file.split('ldblk')[1].split('.ld')[0]

            # Check if the SNP list file exists for this block
            snp_file = os.path.join(chrom_folder, f'blk_{blk_index}')
            if os.path.exists(snp_file):
                # Load the LD matrix
                ld_file_path = os.path.join(chrom_folder, blk_file)
                with open(ld_file_path) as ff:
                    ld = [[float(val) for val in line.strip().split()] for line in ff]
                print(f'Block {int(blk_index)} size {len(ld)}')

                # Load the SNP list
                with open(snp_file) as ff:
                    snplist = [line.strip() for line in ff]

                # Create a new block group in the HDF5 file
                blk_cnt += 1
                hdf_blk = hdf_chr.create_group(f'blk_{blk_cnt}')
                hdf_blk.create_dataset('ldblk', data=sp.array(ld), compression="gzip", compression_opts=9)
                hdf_blk.create_dataset('snplist', data=snplist, compression="gzip", compression_opts=9)
            else:
                print(f'SNP list file missing for block {int(blk_index)}. Skipping.')

    print(f'Chromosome {chrom} processed and saved to {chr_name}')


# Main function to run the script
def main():
    # Get chromosome from environment variable (SLURM_ARRAY_TASK_ID)
    chrom = os.environ.get('SLURM_ARRAY_TASK_ID')

    # Debug: print out SLURM_ARRAY_TASK_ID for verification
    print(f"SLURM_ARRAY_TASK_ID: {chrom}")

    # If the chromosome is not set, raise an error
    if chrom is None:
        print("Error: SLURM_ARRAY_TASK_ID environment variable is not set.")
        sys.exit(1)

    # Convert to integer (chromosome number)
    chrom = int(chrom)

    # Process the specified chromosome
    process_chromosome(chrom)

if __name__ == "__main__":
    main()

