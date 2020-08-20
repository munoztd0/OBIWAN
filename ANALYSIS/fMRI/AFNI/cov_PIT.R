if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr, car)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-04/covariates'

PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

PIT  <- subset(PIT_full, session == 'second')

#take out incomplete data ##
#`%notin%` <- Negate(`%in%`)
#PIT = PIT %>% filter(id %notin% c(242, 256, 114, 208))


#remove the baseline from other trials by id 
PIT =  subset(PIT, condition != 'BL') 

PIT_BL = ddply(PIT, .(id), summarise, freqA=mean(AUC), sdA=sd(AUC)) 
PIT = merge(PIT, PIT_BL, by = "id")
PIT$gripAUC = (PIT$AUC - PIT$freqA) / PIT$sdA

bs = ddply(PIT, .(id, condition), summarise, eff = mean(gripAUC, na.rm = TRUE), auc = mean(AUC, na.rm = TRUE))

CSm = subset(bs, condition == "CSminus")
diff = subset(bs, condition == "CSplus")
diff$eff = diff$eff - CSm$eff
diff$auc = diff$auc - CSm$auc
eff = diff %>% select(id, eff)

ob = subset(eff, id >= 200)
hw = subset(eff, id < 200)

# EFFORT ------------------------------------------------------------------
CSp_CSm_eff_ob = eff
CSp_CSm_eff_hw = eff

CSp_CSm_eff_ob$eff[CSp_CSm_eff_ob$id < 200] <- 0
CSp_CSm_eff_hw$eff[CSp_CSm_eff_hw$id >= 200] <- 0

write.table(CSp_CSm_eff_ob, (file.path(path, "CSp_CSm_eff_ob.txt")), row.names = F, sep="\t")
write.table(CSp_CSm_eff_hw, (file.path(path, "CSp_CSm_eff_hw.txt")), row.names = F, sep="\t")

# INPUT FOR FMRI -------------------------------------------------------------------
#fMRI_PIT = info %>% drop_na(intervention)

