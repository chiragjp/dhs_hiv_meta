library(tidyverse)

corrs <- read_csv('./meta_data/correlation_wealth_education.csv')
corrs <- corrs %>% unite(country_year, country, year, remove= F)
corrs <- corrs %>% mutate(country_year =fct_reorder(country_year, pearson))
corrs <- corrs %>% filter(!is.na(pearson))
 
p <- ggplot(corrs, aes(country_year, pearson))
p <- p + geom_bar(stat="identity")
p <- p + geom_hline(yintercept = mean(corrs$pearson))
p <- p  + coord_flip()
p