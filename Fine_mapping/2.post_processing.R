# Annotate susie results with hg38 chr and pos

library(rtracklayer)

phenotypes <- c("Height", "RBC", "DBP", "Leukocyte", "HDL", "TC", "T2D", "Asthma", "Breast_Cancer", 
                "Colorectal_Cancer")
                
for (phenotype in phenotypes) {
  
  file_path <- paste0("~/Downloads/susie/", phenotype, "_susie_results.tsv")
  df <- read.table(file_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  df$chr <- paste0("chr", df$chr)

  # Create a GRanges object
  gr <- GRanges(seqnames = df$chr, ranges = IRanges(start = df$pos, end = df$pos))

  # Load the liftOver chain file
  chain_file <- "~/Downloads/hg19ToHg38.over.chain"
  chain <- import.chain(chain_file)

  # Perform liftOver
  gr_hg38 <- liftOver(gr, chain)
  df_hg38 <- as.data.frame(gr_hg38)

  # Check the number of successful mappings (non-NA values)
  failed_mappings <- is.na(df_hg38$seqnames)
  print(paste(phenotype, "failed mappings:", sum(failed_mappings)))

  # Create NA columns in df to hold the converted values
  df$chr_hg38 <- NA
  df$pos_hg38 <- NA

  # Keep only successfully mapped rows from df_hg38
  successful_mappings <- !failed_mappings

  # Map the successfully mapped rows back to the original df
  df$chr_hg38[successful_mappings] <- as.character(df_hg38$seqnames[successful_mappings])
  df$pos_hg38[successful_mappings] <- df_hg38$start[successful_mappings]
  df <- df %>% mutate(locus = paste(chr_hg38, pos_hg38, sep = ":"))

  # Remove "chr" prefix for the final output
  df$chr <- gsub("^chr", "", df$chr)
  
  output_file <- paste0("~/Downloads/susie/", phenotype, "_susie_results_w_liftover.tsv")
  write.table(df, output_file, sep = "\t", row.names = FALSE, quote = FALSE)
  
  print(paste(phenotype, "finished"))
}


######

# extract only causal SNPs in sumstats
setwd('~/PRScs')
library(dplyr)
library(tidyr)

phenos <- c("Height", "HDL", "T2D", "Breast_Cancer")

# array
for (phenotype in phenos) {
  
  susie <- read.table(paste0('susie/', phenotype, '_susie_results_w_liftover.tsv'), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  causal <- susie %>% filter(susie_pip > 0.9)
  sst <- read.table(paste0('sst/Array_', phenotype, '_QCed.sst'), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  sst <- sst %>%
    mutate(locus = sub("^(chr[0-9XY]+:[0-9]+).*", "\\1", SNP))
  
  sst_causal <- sst %>%
    semi_join(causal, by = "locus") %>%
    select(-locus) 
  
  write.table(sst_causal, paste0("~/PRScs/sst/QC_causal/Array_", phenotype, "_QC_causal.sst"), sep = "\t", row.names = FALSE, quote = FALSE)
 
  print(paste("Processed", phenotype))
}

# WGS
for (phenotype in phenos) {
  
  susie <- read.table(paste0('susie/', phenotype, '_susie_results_w_liftover.tsv'), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  causal <- susie %>% filter(susie_pip > 0.9)
  sst <- read.table(paste0('sst/WGS_', phenotype, '_QCed.sst'), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  sst <- sst %>%
    mutate(locus = sub("^(chr[0-9XY]+:[0-9]+).*", "\\1", SNP))
  
  sst_causal <- sst %>%
    semi_join(causal, by = "locus") %>%
    select(-locus) 
  
  write.table(sst_causal, paste0("~/PRScs/sst/QC_causal/WGS_", phenotype, "_QC_causal.sst"), sep = "\t", row.names = FALSE, quote = FALSE)
 
  print(paste("Processed", phenotype))
}
