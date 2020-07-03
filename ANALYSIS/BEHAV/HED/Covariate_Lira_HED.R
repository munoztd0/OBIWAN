if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04_1/covariates'

HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

HED  <- subset(HED_full, group == 'obese')
#take out incomplete data ##
#`%notin%` <- Negate(`%in%`)
#HED = HED %>% filter(id %notin% c(242, 256, 114, 208))

bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
emp = subset(bs, condition == "Empty")
ms = subset(bs, condition == "MilkShake")

diff = ms
diff$lik = diff$lik - emp$lik
diff$int = diff$int - emp$int
diff$fam = diff$fam - emp$fam


# LIKING ------------------------------------------------------------------
lik = diff %>% select(id, lik)
emplik = emp %>% select(id, lik)
mslik = ms %>% select(id, lik)

ob = subset(lik, id >= 200)
hw = subset(lik, id < 200)

rew_con_lik_ob = lik
rew_con_lik_hw = lik

rew_con_lik_ob$lik[rew_con_lik_ob$id < 200] <- 0
rew_con_lik_hw$lik[rew_con_lik_hw$id >= 200] <- 0

#write.table(rew_con_lik_ob, (file.path(path, "rew_con_lik_ob.txt")), row.names = F, sep="\t")
#write.table(rew_con_lik_hw, (file.path(path, "rew_con_lik_hw.txt")), row.names = F, sep="\t")

#write.table(mslik, (file.path(path, "rew_lik.txt")), row.names = F, sep="\t")
#write.table(emplik, (file.path(path, "con_lik.txt")), row.names = F, sep="\t")



# INTENSITY ------------------------------------------------------------------
int = diff %>% select(id, int)
empint = emp %>% select(id, int)
msint = ms %>% select(id, int)

ob = subset(int, id >= 200)
hw = subset(int, id < 200)

rew_con_int_ob = int
rew_con_int_hw = int

rew_con_int_ob$int[rew_con_int_ob$id < 200] <- 0
rew_con_int_hw$int[rew_con_int_hw$id >= 200] <- 0

#write.table(rew_con_int_ob, (file.path(path, "rew_con_int_ob.txt")), row.names = F, sep="\t")
#write.table(rew_con_int_hw, (file.path(path, "rew_con_int_hw.txt")), row.names = F, sep="\t")
#write.table(msint, (file.path(path, "rew_int.txt")), row.names = F, sep="\t")
#write.table(empint, (file.path(path, "con_int.txt")), row.names = F, sep="\t")

# Odor_NoOdor_lik <- read.delim(file.path(analysis_path, "Odor-NoOdor_lik_meancent.txt"))
# Odor_presence_lik <- read.delim(file.path(analysis_path, "Odor_presence_lik_meancent.txt"))
# reward_neutral_lik <- read.delim(file.path(analysis_path, "reward-neutral_lik_meancent.txt"))
# R_NoR_lik <- read.delim(file.path(analysis_path, "Reward_NoReward_lik_meancent.txt"))

# INPUT FOR FMRI -------------------------------------------------------------------
bs_HED = ddply(HED, .(id, condition,session), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 

#merge with info
fMRI_HED = merge(bs_HED, info, by = "id")
fMRI_HED$time = as.factor(revalue(fMRI_HED$session, c(second="0", third="1")))
fMRI_HED$condition = as.factor(revalue(fMRI_HED$condition, c(MilkShake="Reward", Empty="Neutral")))

fMRI_HED <- fMRI_HED %>% 
  group_by(id) %>% 
  mutate(diff_bmiZ = scale(BMI_t1 - BMI_t2))

fMRI_HED <- fMRI_HED %>% 
  group_by(id) %>% 
  mutate(bmiZ = scale(BMI_t1))

fMRI_HED <- fMRI_HED %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#routine to make it nice and "simple" for 3dLME
init = 1:length(fMRI_HED$id)
fMRI_HED$InputFile <- init
idx = unique(fMRI_HED$id)
#go through each participant
for(i in 1:length(idx)) {
  fMRI_HED$InputFile[fMRI_HED$id == idx[i] & fMRI_HED$condition == 'Reward' & fMRI_HED$time == 0] <- paste('/home/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04_0/group/sub-obese', idx[i], '_con-0006.nii \\', sep ='')
  fMRI_HED$InputFile[fMRI_HED$id == idx[i] & fMRI_HED$condition == 'Neutral' & fMRI_HED$time == 0] <- paste('/home/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04_0/group/sub-obese', idx[i], '_con-0007.nii \\', sep ='')
  fMRI_HED$InputFile[fMRI_HED$id == idx[i] & fMRI_HED$condition == 'Reward' & fMRI_HED$time == 1] <- paste('/home/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04_1/group/sub-obese', idx[i], '_con-0006.nii \\', sep ='')
  fMRI_HED$InputFile[fMRI_HED$id == idx[i] & fMRI_HED$condition == 'Neutral' & fMRI_HED$time == 1] <- paste('/home/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04_1/group/sub-obese', idx[i], '_con-0007.nii \\', sep ='')
}

colnames(fMRI_HED)[colnames(fMRI_HED) == 'id'] <- 'Subj'
fMRI_HED$diff_bmiZ = round(fMRI_HED$diff_bmiZ, digits = 2)
fMRI_HED$bmiZ = round(fMRI_HED$bmiZ, digits = 2)
fMRI_HED$ageZ = round(fMRI_HED$ageZ, digits = 2)
HED_LME <- fMRI_HED[names(fMRI_HED) %in% c("Subj", "condition", "intervention","time", "gender", "bmiZ", "ageZ", "InputFile")]
colnames(HED_LME)[colnames(HED_LME) == 'InputFile'] <- 'InputFile \\'
path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/HED/'

write.table(HED_LME, (file.path(path, "HED_LME_4.txt")), row.names = FALSE, sep="\t", quote=FALSE)


