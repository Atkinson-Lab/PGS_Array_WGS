library(data.table)
library(GenomicRanges)  # BiocManager::install("GenomicRanges")
library(SNPlocs.Hsapiens.dbSNP155.GRCh37)  # BiocManager::install("SNPlocs.Hsapiens.dbSNP155.GRCh37")

input_files <- c('Asthma_filtered.tsv', 'Breast_Cancer_filtered.tsv', 'Colorectal_Cancer_filtered.tsv', 
                 'DBP_filtered.tsv', 'HDL_filtered.tsv', 'Height_filtered.tsv', 
                 'leukocyte_filtered.tsv', 'RBC_filtered.tsv', 'T2D_filtered.tsv', 'TC_filtered.tsv')

for (input_file in input_files) {
  
  df <- fread(input_file, sep = '\t')
  
  # Perform QC to thin the file
  df <- df[!(nchar(df$ref) > 1 | nchar(df$alt) > 1), ]  # Remove indels (nucleotide length > 1)
  df <- df[!duplicated(df$pos), ]  # Remove duplicated positions
  
  # Create GenomicPositions object
  gwas_positions <- GPos(seqnames = Rle(df$chr), pos = df$pos)
  
  # Load the SNPs from dbSNP155
  snps <- SNPlocs.Hsapiens.dbSNP155.GRCh37
  
  # Increase available memory for processing
  mem.maxVSize(64000)  # Increase memory from 16GB to 64GB
  
  # Find the known SNPs that overlap with the input GWAS positions
  known_snps <- snpsByOverlaps(snps, gwas_positions)  # Time consuming step
  
  # Find overlaps between GWAS positions and known SNPs
  hits <- findOverlaps(gwas_positions, known_snps)
  mapping <- selectHits(hits, select = "first")
  
  # Add the rsID to the original data
  mcols(gwas_positions)$RefSNP_id <- mcols(known_snps)$RefSNP_id[mapping]  # Add rsID to mcols of gwas_positions
  
  # Merge the rsID into the original data frame
  snp_df <- merge(df, gwas_positions, by = "pos", all.x = TRUE)  # Keep all rows from df (left join)
  
  # Output the result to a file
  output_file <- paste0('rsID_', input_file)  # Create output filename
  write.table(snp_df, output_file, sep = '\t', quote = F, row.names = F)
  
  # Free up memory by removing large objects after processing each file
  rm(df, gwas_positions, snps, known_snps, hits, mapping, snp_df)
  gc()  # Garbage collection to free up memory
}
