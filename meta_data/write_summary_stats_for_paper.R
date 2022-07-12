## 07/12/22
## convert to csv for Zenodo
## in Prep for Comm Med

load('./hiv_summary_stats_combined_032419.Rdata')

write.csv(hiv, file="../HIV XWAS Manuscript/NHB/CommsMed Accepted Submission/v2/Zenodo/hiv_summary_by_survey.csv")