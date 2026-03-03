library(dplyr)

### quant traits ###

calculate_prs_r2 <- function(prs_data, phenotype_list, phenotype_names) {
  
  results <- list()
  
  for (i in 1:length(phenotype_list)) {
    
    phenotype <- phenotype_list[[i]]  
    phenotype_name <- phenotype_names[i] 
    
    colnames(phenotype)[1] <- "IID"
    
    merged_data <- merge(phenotype, prs_data[, c("IID", "SCORE")], by = "IID")
    N <- nrow(phenotype)
    
    null_data <- merged_data %>% select(y, age, sex, PC1:PC10)
    full_data <- merged_data %>% select(y, age, sex, PC1:PC10, "SCORE")
    null_r2 <- summary(lm(y ~ ., data = null_data))$r.squared
    full_r2 <- summary(lm(y ~ ., data = full_data))$r.squared
    prs_r2 <- full_r2 - null_r2
    
    results[[phenotype_name]] <- data.frame(
      Phenotype = phenotype_name,
      N = N,
      Null_R2 = null_r2,
      Full_R2 = full_r2,
      PRS_R2 = prs_r2
    )
  }
  
  results_df <- do.call(rbind, results)
  return(results_df)
}


### binary traits ###

calculate_nk_r2 <- function(prs_data, phenotype_list, phenotype_names) {
  
  results <- list()
   
  for (i in 1:length(phenotype_list)) {
    
    phenotype <- phenotype_list[[i]]  
    phenotype_name <- phenotype_names[i] 
    
    colnames(phenotype)[1] <- "IID"
    
    merged_data <- merge(phenotype, prs_data[, c("IID", "SCORE")], by = "IID")
    N <- nrow(phenotype)
    
    null_data <- merged_data %>% select(is_case, age, sex, PC1:PC10)
    full_data <- merged_data %>% select(is_case, age, sex, PC1:PC10, "SCORE")
    null_model <- glm(is_case ~ ., data = null_data, family = binomial)
    full_model <- glm(is_case ~ ., data = full_data, family = binomial)
    LL0 <- logLik(null_model)
    LL1 <- logLik(full_model)
    
    CSr2 <- 1 - exp((2 / N) * (LL0[1] - LL1[1]))
    NKr2 <- CSr2 / (1 - exp((2 / N) * LL0[1]))
    
    results[[phenotype_name]] <- data.frame(
      Phenotype = phenotype_name,
      N = N,
      NK_R2 = NKr2
    )
  }
  
  results_df <- do.call(rbind, results)
  return(results_df)
}


###### call the function
base_path <- "~/pgs_catalog/prs/imputation/"

prs_data <- read.table(paste0(base_path, "Height_Yengo_hm.prs.profile"), header = TRUE)
phenotype_list <- list(height_EUR, height_AMR, height_AFR, height_EAS, height_CSA)
phenotype_names <- c("height_Y_EUR", "height_Y_AMR", "height_Y_AFR", "height_Y_EAS", "height_Y_CSA")

Height_Yengo_result <- calculate_prs_r2(prs_data, phenotype_list, phenotype_names)

###### repeat for other phenotypes
