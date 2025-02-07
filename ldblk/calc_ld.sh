#!/usr/bin/bash
#SBATCH --array=1-22

set -e

# Get chromosome number from the SLURM array task ID
CHR=$SLURM_ARRAY_TASK_ID

cd ~/ldblk/hgdp1kg/hg38

# Directories for input/output
dir_blk="."
dir_1kg="./data/eur/qc"

# Loop over all blk files in the chr folder
for blk_file in ${dir_blk}/chr${CHR}/blk_*; do
    # Extract the block number (assuming blk file is named like blk_1.txt, blk_2.txt, etc.)
    blk=$(basename ${blk_file} .txt | cut -d'_' -f2)

    # Run PLINK for each block
    plink \
        --bfile ${dir_1kg}/hgdp1kgp_qc_chr${CHR} \
        --keep-allele-order \
        --extract ${blk_file} \
        --r square \
        --out ${dir_blk}/chr${CHR}/ldblk${blk} \
        --memory 4000
done
