# Chirag J Patel
# prepare script for correlation
# see rcorr.R

directory_path <- './Data'
countries <- dir(directory_path)

USE_O2 <- T

for(country in countries) {
  surveys <- dir(file.path(directory_path, country))
  for(survey in surveys) {
    files <- (dir(file.path(directory_path, country, survey)))
    if("flattenedfile.encoded.rds" %in% files) {
      filein <- file.path(directory_path, country, survey, 'flattenedfile.encoded.rds')
      fileout <- sprintf('%s_%s_corr.rds', country, survey)
      o2_cmd <- ''
      cmd <- sprintf('Rscript corr.R -i %s -o %s\n', o2_cmd, filein, fileout)
      if(USE_O2) {
        o2_cmd <- sprintf('sbatch -p short --mem 2GB -t 0-01:00 -o %s_%s.out -e %s_%s.err --wrap ', country, survey, country, survey)
        cmd <- sprintf('%s "Rscript corr.R -i %s -o %s"\n', o2_cmd, filein, fileout)
      }
      cat(cmd)
    }
  }
}