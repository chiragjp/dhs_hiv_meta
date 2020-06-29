# Chirag J Patel
# Estimate the correlation matrix of the survey variables
# Chirag J Patel
# 

library(Hmisc)
library(tidyverse)
library(getopt)
spec = matrix(c(
  'filein', 'i', 1, "character",
  'fileout', 'o', 1, "character"
), byrow=TRUE, ncol=4)
opt = getopt(spec)

filepath <- opt$filein #'./flattenedfile.encoded.rds'
outfile <- opt$fileout


encoded <- read_rds(filepath)
encoded_n <- encoded %>% keep(~is.numeric(.))
## split up into males and females and re-run corr


start_time <- Sys.time()

print('running first correlation [males]')
cr_0 <- rcorr(as.matrix(encoded_n %>% filter(hv104_1 == 0)))

print('running second correlation [females]')
cr_1 <- rcorr(as.matrix(encoded_n %>% filter(hv104_1 == 1)))

end_time <- Sys.time()
total_time <- end_time-start_time
print(total_time)

crs <- list(corr_0=cr_0, corr_1=cr_1)

write_rds(crs, path=outfile)

