# Build hg38 LD matrix

### Datasets: 
To build the EUR LD matrix using genome-wide SNPs, we downloaded the hg38 EUR LD blocks from here:
```
git clone https://github.com/jmacdon/LDblocks_GRCh38.git
```
The genotype we used was from the 1kGP and HGDP joint call set, which was downloaded from our internal server at the time of analysis. 

The following scripts were used in sequence to build the hg38 LD matrix. They were inspired by PRS-CS, with modifications to fit our dataset. See their instruction:
https://github.com/getian107/PRScs/issues/13#issuecomment-632860500

### Scripts:
- `1.extract_eur.sh`: Script that extracts unrelated EUR samples from the joint call set.
- `2.qc.sh`: Script for variant QC.
- `3.annotate_maf.sh`: Script that annotates MAF information.
- `4.extract_snp.sh`: Script that extracts SNP column.
- `5.reformat_eur_ldblk.sh`: Script that reformats `pyrho_EUR_LD_blocks.bed`.
- `6.make_snpList.py`: Script that assigns SNPs within the range of each LD block.
  - For each chromosome (e.g., `chr1`, `chr2`, etc.), there should be a folder named after the chromosome.
  - Inside each folder, there will be several text files, each named after the **fifth column (`ref_blk`)** from the reference file (pyrho_EUR_LD_blocks).
  - Each text file will contain SNP IDs from the input file where the SNP's position falls within the range specified by the corresponding block in the reference file.
- `7.combine_ld_snp.sh`: Script that combines all SNP IDs from each LD block into one single list.
- `8.calc_ld.sh`: Script that computes LD matrix for each LD block.
- `9.write_ldblk.py`: Script that saves LD matrices into HDF5 foramt.
- `10.all_snpinfo.sh`: Script that generates relevent SNP information, similar to the snpinfo_1kg_hm3 used in PRS-CS.
- `11.final_ld_snp.py`: Script 10 includes all SNPs in our dataset. Script 11 subsets the SNPs that included in the LD computation only. This is the final SNP list that will be used to run PRS-CS, along with the LD panel.

