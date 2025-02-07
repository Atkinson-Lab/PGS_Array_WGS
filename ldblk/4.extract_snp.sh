#!/bin/bash

cd ~/ldblk/data/eur/qc

for CHR in {1..22}; do
  # Define the input and output file paths
  VCF_FILE="./hgdp1kgp_qc_chr${CHR}.eur_qc.vcf.gz"
  OUTPUT_FILE="./hgdp1kgp_qc_chr${CHR}.eur_snpList.txt"

  # Extract the first three columns, excluding comment lines
  zcat $VCF_FILE | awk '!/^##/ {print $1, $2, $3}' > $OUTPUT_FILE
  
done
