# PGS-Catalog

### Scripts used for UKBB have the suffix "_ukbb". These were applied to UKBB imputation data. The codes for direct genotyping data are very similar:

- `1.harmonization_ukbb.R`: Script that fixes allele mismatching between discovery and target data.
- `2.pgs_ukbb.sh`: Script that runs PGS on the UKBB cohort based on pre-trained models from PGS-Catalog (scoring file).
- `3.r2_ukbb.R`: Script that computes R<sup>2 </sup> for PGS. 


### The script for AoU here was applied to WGS data, but is very similar for array data:
- `PGS_Catalog_on_AoU.ipynb`: Script that runs PGS on the AoU cohort based on pre-trained models from PGS-Catalog (scoring file).
