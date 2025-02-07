#!/bin/bash 
#SBATCH --array=1-10                        

   

# Read the phenotype and n_gwas for the current task
phenotype=$(sed -n "$((SLURM_ARRAY_TASK_ID))p" phenotype_list.txt | awk '{print $1}')
n_gwas=$(sed -n "$((SLURM_ARRAY_TASK_ID))p" phenotype_list.txt | awk '{print $2}')

# Define directories
ref_dir="ldblk_ukbb_eur"	#or "ldblk_hgdp1kg_eur_hg38"
bim_prefix="bim/Array_Vars_QCed_dbsnp"		#or "Array_Vars_QCed"
sst_file="sst/Array_${phenotype}_QCed_dbsnp.sst"	#or "Array_${phenotype}_QCed.sst
out_dir="out/cs_auto"
out_prefix="${out_dir}/${phenotype}"

# Run the PRS-CS command
python3 PRScs/PRScs.py \
  --ref_dir=${ref_dir} \
  --bim_prefix=${bim_prefix} \
  --sst_file=${sst_file} \
  --n_gwas=${n_gwas} \
  --out_dir=${out_prefix} \
  --seed=12345
