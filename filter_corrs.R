## filter correlations for those that were found in multiple cohorts
## from directory: './hiv_corrs'
library(tidyverse)

####
variable_labels <- readRDS('variable_level_labels_ALL_f.rds') %>% mutate(
  var_lvl = case_when(!is.na(lvl) ~ paste(var, lvl, sep="_"),
                      TRUE ~ var)
)

variable_label_unique <- variable_labels %>% group_by(var_lvl) %>% summarize(var=first(var), var_lbl=first(var_lbl), lvl_lbl=first(lvl_lbl))
load('./meta_data/meta_combined.Rdata')
### by variable annotation
categories <- read_tsv('./dd.common.final.tsv')
meta_combined_simple <- merge(meta_combined_simple, categories[ ,c('Variable', 'category')], by.x='name', by.y='Variable', all.x = T)
meta_combined_simple <- meta_combined_simple %>% left_join(variable_label_unique, by=c('name'='var_lvl'))
sigVars <- (meta_combined_simple %>% filter(pvalue < 1e-10) %>% select(name))[[1]]

filter_corr <- function(countryCorr, vars) {
  lcl <- function(corr, vars) {
    varsInCor <- rownames(corr)
    inBoth <- intersect(vars, varsInCor)
    corr <- corr[varsInCor %in% inBoth, varsInCor %in% inBoth]
  }
  cr_0 <- lcl(countryCorr$corr_0$r, vars)
  cr_1 <- lcl(countryCorr$corr_1$r, vars)
  list(corr_0=cr_0, corr_1=cr_1)
}

corr_to_df <- function(countryCorrFiltered) {
  corr_0_df <- data.frame(row=rownames(countryCorrFiltered$corr_0)[row(countryCorrFiltered$corr_0)[upper.tri(countryCorrFiltered$corr_0)]], 
                          col=colnames(countryCorrFiltered$corr_0)[col(countryCorrFiltered$corr_0)[upper.tri(countryCorrFiltered$corr_0)]], 
                          corr=countryCorrFiltered$corr_0[upper.tri(countryCorrFiltered$corr_0)])
  
  corr_1_df <- data.frame(row=rownames(countryCorrFiltered$corr_1)[row(countryCorrFiltered$corr_1)[upper.tri(countryCorrFiltered$corr_1)]], 
                          col=colnames(countryCorrFiltered$corr_1)[col(countryCorrFiltered$corr_1)[upper.tri(countryCorrFiltered$corr_1)]], 
                          corr=countryCorrFiltered$corr_1[upper.tri(countryCorrFiltered$corr_1)])
  corr_0_df$sex_code <- 0
  corr_1_df$sex_code <- 1
  rbind(corr_0_df, corr_1_df) 
}

parse_file_name <- function(filename) {
  arr <- unlist(strsplit(filename, '\\_'))
  N <- length(arr)
  year <- arr[N-1]
  survey_type <- arr[N-2]
  survey_standard <- arr[N-3]
  country <- paste(arr[1:(N-4)], collapse = " ")
  list(country=country, year=year, survey_type=survey_type, survey_standard=survey_standard)
}


corr_files <- dir('./hiv_corrs/')
corr_matrix <- list()
corr_dfs <- list()
corr_info <- list()
for(i in 1:length(corr_files)) {
  corr_file <- corr_files[i]
  print(corr_file)
  corr_file_info <- parse_file_name(corr_file)
  filepath <- file.path('./hiv_corrs/', corr_file)
  countryCorr <- read_rds(filepath)
  countryCorrFiltered <- filter_corr(countryCorr, sigVars)
  corr_df <- corr_to_df(countryCorrFiltered)
  corr_df$country <- corr_file_info$country
  corr_df$year <- corr_file_info$year
  corr_dfs[[i]] <- corr_df
  corr_matrix[[i]] <- countryCorrFiltered
  corr_info[[i]] <- corr_file_info
}



#write_rds(countryCorrFiltered, path=outfile)

