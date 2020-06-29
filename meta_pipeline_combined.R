## Execute a meta-analysis over everything
## Chirag Patel
## 3/24/2019

library('tidyverse')
library('metafor')
library('DT')
load('./meta_data/hiv_summary_stats_combined_032419.Rdata') ## see directory_traverse.R


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


cat('meta-analysis over variable and gender\n')
meta_combined <- hiv %>% group_by(name, gender) %>% nest() 
meta_combined <- meta_combined %>% mutate(model = map(data, safely(~(meta_for_one(.x$estimate, .x$se)))))


cat('compiling results...\n')
meta_tidy <- meta_combined$model %>% map_df(~tidy_meta(.x$result))
meta_combined <- meta_combined %>% cbind(meta_tidy)

meta_combined <- meta_combined %>% mutate(mean_r2=map_dbl(data,~mean(.x$Nag.r2, na.rm=T)))
meta_combined$num_surveys <- cut(meta_combined$k, breaks=c(0,1,3,10,50))

meta_combined_simple <- meta_combined %>% select(-c(data,model))


write_csv(meta_combined_simple, path='./meta_data/meta_combined_simple.csv')

save(meta_combined_simple,meta_combined, file='./meta_data/meta_combined.Rdata')







