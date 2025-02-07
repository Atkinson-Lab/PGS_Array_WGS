#!/usr/bin/bash
#SBATCH --array=1-22

module load bcftools

chr=${SLURM_ARRAY_TASK_ID}

input_dir="ldblk/data/eur/qc"
output_dir="ldblk/data/eur/qc"

# add MAF tags
bcftools +fill-tags ${input_dir}/hgdp1kgp_qc_chr${chr}.eur_qc.vcf.gz -Ou -- -t MAF | \
bcftools annotate -x ^INFO/MAF -Oz -o ${output_dir}/hgdp1kgp_qc_chr${chr}.eur_qc.maf.vcf.gz \
&& bcftools index -c ${output_dir}/hgdp1kgp_qc_chr${chr}.eur_qc.maf.vcf.gz

echo "# Complete"
