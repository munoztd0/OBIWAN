if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr, car)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-02/group_covariates'

PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

PIT  <- subset(PIT_full, group == 'obese')
info = info %>% drop_na(intervention)
#take out incomplete data ##
#`%notin%` <- Negate(`%in%`)
#PIT = PIT %>% filter(id %notin% c(242, 256, 114, 208))


#remove the baseline from other trials by id 
PIT =  subset(PIT, condition != 'BL') 

PIT_BL = ddply(PIT, .(id), summarise, freqA=mean(AUC), sdA=sd(AUC)) 
PIT = merge(PIT, PIT_BL, by = "id")
PIT$gripAUC = (PIT$AUC - PIT$freqA) / PIT$sdA

bs = ddply(PIT, .(id, condition, session), summarise, eff = mean(gripAUC, na.rm = TRUE), auc = mean(AUC, na.rm = TRUE))

CSm = subset(bs, condition == "CSminus")
diff = subset(bs, condition == "CSplus")
diff$eff = diff$eff - CSm$eff
diff$auc = diff$auc - CSm$auc
eff = diff %>% select(id, eff, session)

ob = subset(eff, id >= 200)
hw = subset(eff, id < 200)

# EFFORT ------------------------------------------------------------------
CSp_CSm_eff_ob = eff
CSp_CSm_eff_hw = eff

CSp_CSm_eff_ob$eff[CSp_CSm_eff_ob$id < 200] <- 0
CSp_CSm_eff_hw$eff[CSp_CSm_eff_hw$id >= 200] <- 0

#write.table(CSp_CSm_eff_ob, (file.path(path, "CSp_CSm_eff_ob.txt")), row.names = F, sep="\t")
#write.table(CSp_CSm_eff_hw, (file.path(path, "CSp_CSm_eff_hw.txt")), row.names = F, sep="\t")

# INPUT FOR FMRI -------------------------------------------------------------------
fMRI_PIT = merge(bs, info, by = "id")

fMRI_PIT <- fMRI_PIT %>% 
  group_by(id) %>% 
  mutate(diff_bmi = scale(BMI_t1 - BMI_t2))

fMRI_PIT <- fMRI_PIT %>% 
  group_by(id) %>% 
  mutate(age = scale(age))

fMRI_PIT <- fMRI_PIT %>% 
  group_by(id) %>% 
  mutate(BMI = scale(BMI_t1))


fMRI_PIT$time = as.factor(revalue(fMRI_PIT$session, c(second="0", third="1")))
IDX = unique(fMRI_PIT$id)
init <- 1:length(fMRI_PIT$id)
fMRI_PIT$InputFile = init
for(i in 1:length(IDX)){
fMRI_PIT$InputFile[fMRI_PIT$condition == 'CSplus' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/cisa/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/ses-1/sub-obese',IDX[1],'_con-0001', sep ='')
fMRI_PIT$InputFile[fMRI_PIT$condition == 'CSminus' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/cisa/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/ses-1/sub-obese',IDX[1],'_con-0002', sep ='')
fMRI_PIT$InputFile[fMRI_PIT$condition == 'CSplus' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/cisa/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/ses-2/sub-obese',IDX[1],'_con-0001', sep ='')
fMRI_PIT$InputFile[fMRI_PIT$condition == 'CSminus' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/cisa/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/ses-2/sub-obese',IDX[1],'_con-0002', sep ='')
}
colnames(fMRI_PIT)[colnames(fMRI_PIT) == 'id'] <- 'Subj'
PIT_df <- fMRI_PIT[, which(names(fMRI_PIT) %in% c("Subj", "time", "BMI", "diff_bmi", "gender", "InputFile"))]

