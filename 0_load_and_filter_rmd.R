# Chirag
# load and filter data for .rmds

library(tidyverse)
# variable labels contains the variable ID ('var'), the label , the level (if a categorical variable), level label, and survey of origin
variable_labels <- read_rds('variable_level_labels_ALL_f.rds') %>% mutate(
  var_lvl = case_when(!is.na(lvl) ~ paste(var, lvl, sep="_"),
                      TRUE ~ var)
)


variable_label_unique <- variable_labels %>% group_by(var_lvl) %>% summarize(var=first(var), var_lbl=first(var_lbl), lvl_lbl=first(lvl_lbl))


### by variable annotation from the group (crowdsourced)
categories <- read_tsv('./dd.common.final.tsv')

## load in the main results file - this contains the meta-analytic model and data all in one big data frame
load('./meta_data/meta_combined.Rdata')
# meta combined simple only contains the summary statistics
meta_combined_simple <- merge(meta_combined_simple, categories[ ,c('Variable', 'category')], by.x='name', by.y='Variable', all.x = T)
meta_combined_simple <- meta_combined_simple %>% left_join(variable_label_unique, by=c('name'='var_lvl'))


## load in data for individual countries
load('./meta_data/meta_country_simple.Rdata')
meta_country_simple <- merge(meta_country_simple, categories[ , c('Variable', 'category')], by.x='name', by.y='Variable', all.x=T)
meta_country_simple <- (meta_country_simple %>% left_join(variable_label_unique, by= c("name"="var_lvl")))

to_remove_vars <- c('sh235_2','sh235a_2','s124','s1001g','sh165','sh21a','s502','sprelim','s810a','sh235a_3','shiv51','sh235_3','sh540_c','sh235a_1','sh235_1',
'sh279a_2','sh279_2','sh540c','srecent','hiv07','s928b','sh279a_1','sh279_1','s1317','sm714b','hiv08','s521b','s923d','sm822','srecent','sprelim','shiv51',
'hiv07','hiv06','s928b','sh235_1','sh235a_1','<NA>','sh279a_1','sh279_1','s1317','sm714b','hiv08','s529_1','sh525c_1','sh525c_2','hivline','hivnumb'
)

### As of 6/6, remove var that do not have labels (in addition to the above)
# %>% filter(mean_r2 < .1)
meta_combined_simple_filtered <- meta_combined_simple %>% arrange(desc(mean_r2)) 
meta_combined_simple_filtered <- meta_combined_simple_filtered %>% filter(!(var %in% to_remove_vars))
meta_combined_simple_filtered <- meta_combined_simple_filtered %>% filter(!is.na(var)) %>% filter(!is.na(k))
meta_country_simple_filtered <- meta_country_simple %>% filter(!(var %in% to_remove_vars))
meta_country_simple_filtered <- meta_country_simple_filtered %>% filter(!is.na(var), !is.na(beta))
meta_country_simple_filtered <- meta_country_simple_filtered %>% filter(name %in% meta_combined_simple_filtered$name)

### count the variables
length(unique(meta_country_simple_filtered$name))
length(unique(meta_country_simple_filtered$name[meta_country_simple_filtered$gender=='m']))
length(unique(meta_country_simple_filtered$name[meta_country_simple_filtered$gender=='f']))

### As of 11/19, remove variables that are highly correlated with one another
#nodes <- read_csv('./nodes.csv')
## As of 12/16
#keep_nodes_female <- read_csv('./keepNodes.female.abs.csv')
#to_remove_nodes <- filter(nodes, removeVar == 1) %>% select(nodes)
# As of 2/20
keep_nodes_female <- read_csv('./keepNodes/keepNodes.female.abs.02192020.csv')
keep_nodes_male <- read_csv('./keepNodes/keepNodes.male.abs.02192020.csv')

#meta_combined_simple_filtered <- meta_combined_simple_filtered %>% filter(!(name %in% to_remove_nodes$nodes))
#meta_country_simple_filtered <- meta_country_simple_filtered %>% filter(!(name %in% to_remove_nodes$nodes))
keep_nodes_female <- keep_nodes_female %>% filter(keep == 1) %>% select(nodes.female) %>% rename(nodes=nodes.female)
keep_nodes_male <- keep_nodes_male %>% filter(keep == 1) %>% select(nodes.male) %>% rename(nodes=nodes.male)
meta_combined_simple_filtered <- rbind(
  meta_combined_simple_filtered %>% filter(gender == 'm') %>% filter((name %in% keep_nodes_male$nodes)),
  meta_combined_simple_filtered %>% filter(gender == 'f') %>% filter((name %in% keep_nodes_female$nodes))
)

meta_country_simple_filtered <- rbind(
  meta_country_simple_filtered %>% filter(gender == 'm') %>% filter((name %in% keep_nodes_male$nodes)),
  meta_country_simple_filtered %>% filter(gender == 'f') %>% filter((name %in% keep_nodes_female$nodes))
)


### count the variables
length(unique(meta_country_simple_filtered$name))
length(unique(meta_country_simple_filtered$name[meta_country_simple_filtered$gender=='m']))
length(unique(meta_country_simple_filtered$name[meta_country_simple_filtered$gender=='f']))

length(unique(meta_combined_simple_filtered$name))
length(unique(meta_combined_simple_filtered$name[meta_combined_simple_filtered$gender=='m']))
length(unique(meta_combined_simple_filtered$name[meta_combined_simple_filtered$gender=='f']))

save(meta_combined_simple_filtered, meta_country_simple_filtered, file='./meta_data/meta_filtered_data.Rdata')





