if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr, car, misty)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)


load('PIT_LIRA.RData')

PIT = PIT %>% filter(id %notin% c(210, 214, 216, 218, 219, 222, 223, 224, 233, 240, 242, 247, 249, 256, 258, 263, 267)) #& 266??

bs = ddply(PIT, .(id, condition, time, intervention, gender), summarise, eff = mean(AUC, na.rm = TRUE))
bs$eff = scale(bs$eff)
cov = PIT %>% group_by(id) %>% summarise_if(is.numeric, mean)
cov = select(cov, c(id, ageC, likC, bmiC, diff_bmiC, hungryC, thirstyC, pissC))

# COVARIATE ------------------------------------------------------------------

CSp_eff_t0 = subset(bs, time == '0' & condition == 1)
CSp_eff_t1 = subset(bs, time == '1'& condition == 1)
CSm_eff_t0 = subset(bs, time == '0' & condition == -1)
CSm_eff_t1 = subset(bs, time == '1'& condition == -1)


path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_0'
write.table(CSp_eff_t0, (file.path(path, "CSp_eff.txt")), row.names = F, sep="\t")
write.table(CSm_eff_t0, (file.path(path, "CSm_eff.txt")), row.names = F, sep="\t")
path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_1'
write.table(CSp_eff_t1, (file.path(path, "CSp_eff.txt")), row.names = F, sep="\t")
write.table(CSm_eff_t1, (file.path(path, "CSm_eff.txt")), row.names = F, sep="\t")

# INPUT FOR FMRI -------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_PIT = df

IDX = unique(fMRI_PIT$id)
init <- 1:length(fMRI_PIT$id)
fMRI_PIT$InputFile = init
for(i in 1:length(IDX)){
  fMRI_PIT$InputFile[fMRI_PIT$condition == '1' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_0/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '-1' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_0/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '1' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_1/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '-1' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01_1/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_PIT)[colnames(fMRI_PIT) == 'id'] <- 'Subj'

fMRI_PIT[is.na(fMRI_PIT)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/'
write.table(fMRI_PIT, (file.path(path, "PIT_LME_withcov.txt")), row.names = F, sep="\t")


# INPUT FOR FMRI already eff-------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_PIT = df

IDX = unique(fMRI_PIT$id)
init <- 1:length(fMRI_PIT$id)
fMRI_PIT$InputFile = init
for(i in 1:length(IDX)){
  fMRI_PIT$InputFile[fMRI_PIT$condition == '1' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '-1' & fMRI_PIT$time == 0 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '1' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PIT$InputFile[fMRI_PIT$condition == '-1' & fMRI_PIT$time == 1 & fMRI_PIT$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_PIT)[colnames(fMRI_PIT) == 'id'] <- 'Subj'

fMRI_PIT[is.na(fMRI_PIT)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01'
write.table(fMRI_PIT, (file.path(path, "PIT_LME_withcov.txt")), row.names = F, sep="\t")

# for id in  202 203 204 209 213 217 220 224 225 235 236 237 238 239 241 246 250 259 264 265 266 269 270
# do
# mv *${id}* placebo/
# done
mv sub* treatment/