# Heritability estimation

### Scripts 1 to 5 are used for sumstats preprocessing:

- `1.1.process_sumstats_hq.py` and `1.2.process_sumstats.py`: Scripts for manually processing the sumstats. `1.1` is used for Pan UKBB sumstats that have the `_hq` column.
- `2.annotate_rsID.R`: Since LDSC recognizes rsID, this script annotates SNPs with dbSNP rsIDs.
- `3.convert_pval.sh`: The original p-values in the sumstats have been -log10 transformed. This script transforms them back to the oringinal p-values.
- `4.recol.sh`: Script that changes column names so that munge_sumstats.py can recognize.
- `5.munge_sumstats.sh`: Script adapted from LDSC that further formats the sumstats.
- `6.h2.sh`: Script that computes heritability used in LDSC.

