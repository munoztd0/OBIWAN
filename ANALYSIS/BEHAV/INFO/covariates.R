if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04/covariates'
#path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-04/covariates'

#HED <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset


# LIKING ------------------------------------------------------------------
age_cov = select(info, c(id, age))
age_cov$id = as.numeric(as.character(age_cov$id))
age_cov =na.omit(age_cov)
age_cov <- age_cov[order(age_cov$id),]

bmi_cov = select(info, c(id, BMI_t1))      
bmi_cov$id = as.numeric(as.character(bmi_cov$id))
bmi_cov =na.omit(bmi_cov)
bmi_cov <- bmi_cov[order(bmi_cov$id),]


write.table(age_cov, (file.path(path, "age_cov.txt")), row.names = F, sep="\t")
write.table(bmi_cov, (file.path(path, "bmi_cov.txt")), row.names = F, sep="\t")

