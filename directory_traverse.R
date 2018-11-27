## Chirag J Patel
## traverse the directory for summary statistics
## 

library(tidyverse)
library(readr)
basepath <- './data/univariateresults/'
countries <- dir(basepath)

read_file <- function(pathToFile, country, survey, gender) {
  dat <- read_delim(pathToFile, delim="\t")
  dat$country <- country
  dat$survey <- survey
  dat$gender <- gender
  return(dat)
}

dats <- list()
test_dats <- list()
train_dats <- list()
i <- 1
for(country in countries) {
  #print(country)
  surveys <- (dir(file.path(basepath, country)))
  for(survey in surveys) {
    for(gender in c('m', 'f')) {
      path <- file.path(basepath, country, survey, 'Uni', gender)
      tsv_files <- (dir(path))
      #cat(sprintf('%s\n', path))
      if(length(tsv_files) > 0) {
        #print(tsv_files)
        dats[[i]] <- read_file(file.path(path, 'replicateUnion.tsv'), country, survey, gender)
        test_dats[[i]] <- read_file(file.path(path, 'test.tsv'), country, survey, gender)
        train_dats[[i]] <- read_file(file.path(path, 'train.tsv'), country, survey, gender)
        i <- i + 1
      } else {
        cat(sprintf('%s: no files found\n', path))
      }
    }
  }
}


hiv_replicated <- bind_rows(dats)
hiv_test <- bind_rows(test_dats)
hiv_train <- bind_rows(train_dats)
save(hiv_replicated,hiv_test, hiv_train, file='./hiv_summary_stats.Rdata')