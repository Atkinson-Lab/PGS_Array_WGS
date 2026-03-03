library(mapgen)
library(tidyverse)
library(ggplot2)

LD_Blocks <- readRDS(system.file('extdata', 'LD.blocks.EUR.hg19.rds', package='mapgen'))

region_info <- get_UKBB_region_info(LD_Blocks,
                                    LDREF.dir = "~/Downloads/mapgen/LD",
                                    prefix = "ukb_b37_0.1")

LD_snp_info <- read_LD_SNP_info(region_info)  


###### Process GWAS sumstats

gwas.file <- '~/Downloads/pan_ukb/filtered/p_rsID_Height_filtered.tsv'
gwas.sumstats <- vroom::vroom(gwas.file, col_names = TRUE, show_col_types = FALSE)
n = 438478

gwas.file <- '~/Downloads/pan_ukb/filtered/p_rsID_HDL_filtered.tsv'
gwas.sumstats <- vroom::vroom(gwas.file, col_names = TRUE, show_col_types = FALSE)
n = 385023

gwas.file <- '~/Downloads/pan_ukb/filtered/p_rsID_T2D_filtered.tsv'
gwas.sumstats <- vroom::vroom(gwas.file, col_names = TRUE, show_col_types = FALSE)
n = 438684

gwas.file <- '~/Downloads/pan_ukb/filtered/p_rsID_Breast_Cancer_filtered.tsv'
gwas.sumstats <- vroom::vroom(gwas.file, col_names = TRUE, show_col_types = FALSE)
n = 228581


gwas.sumstats <- process_gwas_sumstats(gwas.sumstats, 
                                       chr='chr', pos='pos', beta='beta_meta',se='se_meta', 
                                       a0='ref', a1='alt', snp='RefSNP_id', pval='pval',
                                       LD_snp_info=LD_snp_info, 
                                       strand_flip=TRUE, 
                                       remove_strand_ambig=TRUE)


# Select GWAS significant loci (pval < 5e-8)

if (max(gwas.sumstats$pval) > 1) {
  gwas.sumstats <- gwas.sumstats %>% dplyr::mutate(pval = 10^(-pval))
}

sig.loci <- gwas.sumstats %>% dplyr::filter(pval < 5e-8) %>% dplyr::pull(locus) %>% unique()
cat(length(sig.loci), "significant loci. \n")




###### Run fine-mapping

# Create an empty list to store the results
all_results <- list()

for (i in 1:length(sig.loci)) {
  locus <- sig.loci[i]
  message("Processing locus ", i, ": ", locus)

  # Use tryCatch to handle errors and continue the loop
  result <- tryCatch({
    ## Subset GWAS
    sumstats.locus <- gwas.sumstats[gwas.sumstats$locus == locus, ]
    
    ## Load LD reference
    LD_ref <- load_UKBB_LDREF(
      LD_Blocks,
      locus,
      LDREF.dir = "~/Downloads/mapgen/LD",
      prefix = "ukb_b37_0.1"
    )

    ## Match GWAS to LD
    matched.sumstat.LD <- match_gwas_LDREF(
      sumstats.locus,
      LD_ref$R,
      LD_ref$snp_info
    )

    sumstats.locus <- matched.sumstat.LD$sumstats
    z.locus <- sumstats.locus$zscore
    R.locus <- matched.sumstat.LD$R
    snp_info.locus <- matched.sumstat.LD$snp_info

    ## Run SuSiE
    susie.locus.res <- susie_finemap_region(
      sumstats.locus,
      R.locus,
      snp_info.locus,
      n = n,
      L = 10
    )

    ## Merge sumstats
    susie.locus.sumstats <- merge_susie_sumstats(
      susie.locus.res,
      sumstats.locus
    )

    # Filter and select relevant columns
    susie.locus.sumstats %>% 
      select(c(chr, pos, beta, pval, snp, locus, susie_pip, cs)) %>% 
      filter(cs > 0)
    
  }, error = function(e) {
    # Print an error message and return NULL so the loop continues
    message("Error with locus ", i, " (", locus, "): ", e$message)
    return(NULL)  # Return NULL if there's an error
  })

  # If the result is not NULL, append it to the list
  if (!is.null(result)) {
    all_results[[i]] <- result
  } else {
    message("Skipping locus ", i, " due to error.")
  }
}

# Combine all results into a single data frame
final_results <- bind_rows(all_results)

