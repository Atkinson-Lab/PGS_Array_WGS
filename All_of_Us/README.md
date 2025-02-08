# All of Us
### 1. Scripts used for C+T have the prefix "`Step`", followed by a number (and letter):

- `Step1_SampleSelection.ipynb`: Code for for selecting AoU samples used in the analysis.
- `Step2_SumStats_QC.ipynb`: Code for GWAS summary statistics QC.
- `Step3_Clumping.ipynb`: Code for LD clumping.
- `Step4_Compute_PGS.ipynb`: Code for computing polygenic scores.
- `Step5_Compute_R2.ipynb`: Code for obtaining performance metrics.
- `a` means code using array genotype; `b` means code using WGS genotype; and `c` means code for WGS genotyping but only in AFR, which underwent further QC.

### 2. Scripts used for PRS-CS have the prefix or suffix "`PRScs`":

- `Export_to_PRScs.ipynb`: Code for generating inputs for running PRS-CS. 
- `PRScs_Compute_PGS.ipynb`: Code for computing polygenic scores with posterior effect sizes inferred from PRS-CS.  
- `PRScs_Compute_R2.ipynb`: Code for computing R<sup>2 </sup>metrics from the above PGS.
- `PRScs_Compute_PGS_hg38.ipynb`: Code for computing polygenic scores with posterior effect sizes inferred from PRS-CS, which used the hg38 whole-genome LD panel.
- `PRScs_Compute_R2_hg38.ipynb`: Code for computing R<sup>2 </sup> metrics from the above PGS.

### 3. R2_Comparsion:

- `R2_Comparison.ipynb`: Code used to generate R<sup>2 </sup> plots from either C+T or PRS-CS.

### 4. Allele frequency:

- `Calculate_AF_all.ipynb`: Code for calculating allele frequency for all traits.
- `Calculate_AF_HDL.ipynb`: Code for calculating allele frequency for HDL only.

### 5. Scripts used for QC have the prefix "`Supp`":

- `Supp_TGP_QC.ipynb`: Code for QC on the 1kGP reference panel.
- `Supp_Array_QC.ipynb`: Code for QC on array variants.
- `Supp_WGS_QC.ipynb`: Code for QC on WGS variants.
- `Supp_WGS_AFR_QC.ipynb`: Code for AFR-specific QC on WGS variants.
