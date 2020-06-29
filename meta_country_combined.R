## Execute a meta-analysis over each country individually
## Chirag Patel
## 3/25/2019

library('tidyverse')
library('metafor')
library('DT')
load('./meta_data/hiv_summary_stats_combined_032419.Rdata') ## see directory_traverse_test_train_combined.R


hiv$year <- unlist(lapply(strsplit(hiv$survey, "\\_"), function(x) { x[3] }))
meta_for_one <- function(estimates, ses, ...) {
  ## Dersimonian-Laird RF
  mod <- rma.uni(yi=estimates, sei=ses, method = 'DL', ...)
  return(mod)
}


tidy_meta <- function(obj) {
  ret <- tibble(beta=NA, se=NA, zval=NA,pvalue=NA,
                tau2=NA, H2=NA, k=NA, I2=NA, QE=NA,QEp=NA)
  if(!is.null(obj)) {
    ret <- tibble(beta=obj$beta[1], se=obj$se, zval=obj$zval,pvalue=obj$pval,
                  tau2=obj$tau2, H2=obj$H2, k=obj$k, I2=obj$I2, QE=obj$QE,QEp=obj$QEp)
  }
  return(ret)
}

cat('meta-analysis on specfic countries\n')
meta_country <- hiv %>% group_by(name, gender, country) %>% nest() 
meta_country <- meta_country %>% mutate(model = map(data, safely(~(meta_for_one(.x$estimate, .x$se)))))


cat('compiling results...\n')
meta_country_tidy <- meta_country$model %>% map_df(~tidy_meta(.x$result))
meta_country <- meta_country %>% cbind(meta_country_tidy)
meta_country <- meta_country %>% mutate(mean_r2=map_dbl(data, ~mean(.x$Nag.r2, na.rm=T)))


cat('writing out files...\n')

meta_country_simple <- meta_country %>% select(-c(data, model))
save(meta_country, meta_country_simple, file='./meta_data/meta_combined_country.Rdata')
save(meta_country_simple, file='./meta_data/meta_country_simple.Rdata')