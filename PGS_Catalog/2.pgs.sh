#!/bin/bash

geno_dir="~/pgs_catalog/genotype"
catalog_dir="~/pgs_catalog/scoring/imputation"
prs_dir="~/pgs_catalog/prs/imputation"

catalog=('Height_Yengo_hm.txt' 'HDL_Kanoni_hm.txt' 'Breast_Cancer_multi_hm.txt' 'Height_EUR_hm.txt' \
         'Height_AFR_hm.txt' 'Height_AMR_hm.txt' 'HDL_AFR_hm.txt' 'T2D_multi_hm.txt')

# Get the current catalog file index from SLURM_ARRAY_TASK_ID
catalog_file="${catalog[$SLURM_ARRAY_TASK_ID]}"
input_file="${catalog_dir}/${catalog_file}"
output_prefix="${prs_dir}/$(basename ${catalog_file} .txt)"

plink \
    --bfile "${geno_dir}/imputation/ukb_imp_all_QC" \
    --score "${input_file}" 6 3 5 header \
    --out "${output_prefix}.prs"
