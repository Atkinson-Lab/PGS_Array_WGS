#!/usr/bin/bash
#SBATCH --array=1-22


module load bcftools

# Path to the sample file
SAMPLES=~/ldblk/data/TGP_HGDP_EUR_unrel.txt

# Directory containing VCF files
VCF_DIR=~/ldblk/data

# Output directory
OUTPUT_DIR=~/ldblk/data/eur

# Get the chromosome number from the array job index
CHR=${SLURM_ARRAY_TASK_ID}

# Define input and output VCF paths
INPUT_VCF="${VCF_DIR}/hgdp1kgp_chr${CHR}.shapeit5_phased.filter1_SNP_maf005.vcf.gz"
OUTPUT_VCF="${OUTPUT_DIR}/hgdp1kgp_qc_chr${CHR}.eur.vcf.gz"

echo "Processing chromosome ${CHR}..."

# Extract samples using bcftools
bcftools view -S "$SAMPLES" -Oz -o "$OUTPUT_VCF" "$INPUT_VCF"

echo "Chromosome ${CHR} output saved to ${OUTPUT_VCF}"

echo "Processing complete for chromosome ${CHR}."

