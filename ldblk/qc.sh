#!/usr/bin/bash
#SBATCH --array=1-22  

PLINK2_DIR=/storage/atkinson/shared_software/software/plink2
cd ~/ldblk/data/eur

CHR=${SLURM_ARRAY_TASK_ID}  # Use the job array index (1-22) as chromosome number

# Check if the input VCF file exists
INPUT_VCF="./hgdp1kgp_qc_chr${CHR}.eur.vcf.gz"
if [ ! -f "$INPUT_VCF" ]; then
    echo "ERROR: Input VCF file $INPUT_VCF does not exist."
    exit 1
fi

# Step 1: Convert VCF to BED, apply MAF filtering, set variant IDs, and handle duplicates
${PLINK2_DIR}/plink2 \
    --vcf "$INPUT_VCF" \
    --maf 0.01 \
    --new-id-max-allele-len 58 \
    --rm-dup exclude-all \
    --set-all-var-ids chr@:#:\$r:\$a \
    --make-bed \
    --out ./qc/hgdp1kgp_qc_chr${CHR}

# Step 2: Export the filtered VCF with updated variant IDs
${PLINK2_DIR}/plink2 \
    --bfile ./qc/hgdp1kgp_qc_chr${CHR} \
    --export vcf bgz \
    --out ./qc/hgdp1kgp_qc_chr${CHR}.eur_qc
