# For impuation data

mem.maxVSize(64000)  
library(data.table)
library(dplyr)  

# Function to find the complementary allele
complement <- function(x) {
  switch (
    x,
    "A" = "T",
    "C" = "G",
    "T" = "A",
    "G" = "C",
    return(NA)
  )
}

# Filter out ambiguous SNPs
filter_ambiguous_snps <- function(catalog) {
  catalog %>%
    filter(
      !( (effect_allele == 'A' & other_allele == 'T') |
         (effect_allele == 'T' & other_allele == 'A') |
         (effect_allele == 'C' & other_allele == 'G') |
         (effect_allele == 'G' & other_allele == 'C') )
    )
}

# Harmonize function to fix allele mismatch
harmonize <- function(catalog, bim) {
  # Merge catalog with bim on 'id' (chr:pos)
  info <- merge(bim, catalog, by = 'id')
  
  # Identify SNPs where effect and other alleles match the reference
  info.match <- subset(info, effect_allele == alt & other_allele == ref)
  
  # Identify SNPs where alleles are complementary
  info$C.A1 <- sapply(info$alt, complement)
  info$C.A2 <- sapply(info$ref, complement)
  info.complement <- subset(info, effect_allele == C.A1 & other_allele == C.A2)
  
  # Identify SNPs that need recoding (effect_allele == ref, other_allele == alt)
  info.recode <- subset(info, effect_allele == ref & other_allele == alt)
  
  # Identify SNPs that need recoding and complement (effect_allele == C.A2, other_allele == C.A1)
  info.crecode <- subset(info, effect_allele == C.A2 & other_allele == C.A1)
  
  # Fix mismatches
  # Complement SNPs: Flip the alleles (complement)
  complement.snps <- catalog$id %in% info.complement$id
  catalog[complement.snps,]$effect_allele <- sapply(catalog[complement.snps,]$effect_allele, complement)
  catalog[complement.snps,]$other_allele <- sapply(catalog[complement.snps,]$other_allele, complement)
  
  # Recode SNPs: Swap effect_allele and other_allele and change sign of beta
  recode.snps <- catalog$id %in% info.recode$id
  tmp <- catalog[recode.snps,]$effect_allele
  catalog[recode.snps,]$effect_allele <- catalog[recode.snps,]$other_allele
  catalog[recode.snps,]$other_allele <- tmp
  catalog[recode.snps,]$beta <- -catalog[recode.snps,]$beta
  
  # Recode and complement SNPs: Swap alleles, complement them, and change sign of beta
  com.snps <- catalog$id %in% info.crecode$id
  tmp <- catalog[com.snps,]$effect_allele
  catalog[com.snps,]$effect_allele <- as.character(sapply(catalog[com.snps,]$other_allele, complement))
  catalog[com.snps,]$other_allele <- as.character(sapply(tmp, complement))
  catalog[com.snps,]$beta <- -catalog[com.snps,]$beta
  
  return(catalog)
}

# Read in the bim file
bim <- fread('genotype/imputation/ukb_imp_all_QC.bim')
colnames(bim) <- c('chr', 'id', 'gd', 'pos', 'alt', 'ref') # Assign appropriate column names
  
# read in catalog
process_file <- function(file_path) {
  fread(file_path, sep = '\t') %>% select('chr_name', 'chr_position', 'effect_allele', 'other_allele', 'effect_weight') %>%
    setNames(c('chr', 'pos', 'effect_allele', 'other_allele', 'beta')) %>%
    mutate(id = paste(chr, pos, sep = ":"))
}

catalogs <- list(
  Height_Yengo = process_file('scoring/PGS002802.txt'),
  HDL_Kanoni = process_file('scoring/PGS002781.txt'),
  Height_EUR = process_file('scoring/PGS005000.txt'),
  Height_AFR = process_file('scoring/PGS004998.txt'),
  Height_AMR = process_file('scoring/PGS004999.txt'),
  HDL_AFR = process_file('scoring/PGS003773.txt'),
  T2D_multi = process_file('scoring/PGS005242.txt'),
  Breast_Cancer_multi = process_file('scoring/PGS000004.txt')
)
                
for (catalog_name in names(catalogs)) {
  # Remove ambiguous SNPs first
  catalogs[[catalog_name]] <- filter_ambiguous_snps(catalogs[[catalog_name]])
  
  # Harmonize the catalog data
  catalogs[[catalog_name]] <- harmonize(catalogs[[catalog_name]], bim)
  
  # Remove all rows where 'id' is duplicated
  catalogs[[catalog_name]] <- catalogs[[catalog_name]] %>%
  group_by(id) %>%
  filter(n() == 1) %>%
  ungroup()

  # Output files
  output_file <- paste0("scoring/imputation/", catalog_name, "_hm.txt")
  fwrite(catalogs[[catalog_name]], file = output_file, sep = '\t')
  cat(paste0("Saved harmonized ", catalog_name, " to ", output_file, "\n"))
}
