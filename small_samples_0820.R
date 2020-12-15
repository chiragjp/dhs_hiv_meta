
library(tidyverse)
library(survey)

load('./meta_data/meta_filtered_data.Rdata')

#hv109_09_2
#v604_6
#hv115_05_4

meta_combined_simple_filtered %>% filter(name == 'hv109_09_2', gender == 'm')
meta_country_simple_filtered %>% filter(name == 'hv109_09_2', gender == 'm') %>% arrange(beta) %>% select(var, var_lbl, lvl_lbl, country, beta, pvalue)

meta_combined_simple_filtered %>% filter(name == 'v604_6', gender == 'm')
meta_country_simple_filtered %>% filter(name == 'v604_6', gender == 'm') %>% arrange(beta) %>% select(var, var_lbl, lvl_lbl,name, country, beta, pvalue)


meta_combined_simple_filtered %>% filter(name == 'hv115_05_4', gender == 'm')
meta_country_simple_filtered %>% filter(name == 'hv115_05_4', gender == 'm') %>% arrange(beta) %>% select(var, var_lbl, lvl_lbl, country, beta, pvalue)

#Namibia

namibia_13 <- read_rds('../Data/Namibia/Standard_DHS_2013/flattenedfile.encoded.rds')
mozam <- read_rds('../Data/Mozambique/Standard_AIS_2009/flattenedfile.encoded.rds')



namibia_13_m <- namibia_13 %>%
  filter(hv104_1 == 1)
dsn <-  svydesign(ids=~hivclust,
                  weights=~hiv05,
                  nest=T,
                  data = namibia_13_m)
indVar <- "hv109_09_2"
depVar <- "hiv03"
formula <- sprintf("%s ~ %s", depVar, indVar)
mod <- svyglm(as.formula(formula), design = dsn, family=quasibinomial)

#0   1
#0 593  46
#1  28   0


