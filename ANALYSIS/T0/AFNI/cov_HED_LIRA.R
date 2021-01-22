if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr, car, misty)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

load('HED_LIRA.RData')

HED = HED %>% filter(id %notin% c(201, 208, 210, 214, 216, 219, 222, 223, 233, 234, 240, 242, 245, 247, 249, 256, 258, 263, 267))

bs = ddply(HED, .(id, condition, time, intervention, gender), summarise, lik = mean(perceived_liking, na.rm = TRUE))
bs$lik = scale(bs$lik)
#cov = HED %>% group_by(id) %>% summarise_if(is.numeric, mean)
#cov = select(cov, c(id, ageC, likC, bmiC, diff_bmiC, hungryC, thirstyC, pissC))

# COVARIATE ------------------------------------------------------------------

REW_lik_t0 = subset(bs, time == '0' & condition == 1)
REW_lik_t1 = subset(bs, time == '1'& condition == 1)
NEU_lik_t0 = subset(bs, time == '0' & condition == -1)
NEU_lik_t1 = subset(bs, time == '1'& condition == -1)


path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_0'
write.table(REW_lik_t0, (file.path(path, "REW_lik.txt")), row.names = F, sep="\t")
write.table(NEU_lik_t0, (file.path(path, "NEU_lik.txt")), row.names = F, sep="\t")
path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_1'
write.table(REW_lik_t1, (file.path(path, "REW_lik.txt")), row.names = F, sep="\t")
write.table(NEU_lik_t1, (file.path(path, "NEU_lik.txt")), row.names = F, sep="\t")

# INPUT FOR FMRI -------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_HED = df

IDX = unique(fMRI_HED$id)
init <- 1:length(fMRI_HED$id)
fMRI_HED$InputFile = init
for(i in 1:length(IDX)){
  fMRI_HED$InputFile[fMRI_HED$condition == '1' & fMRI_HED$time == 0 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/HED/GLM-01_0/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '-1' & fMRI_HED$time == 0 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/HED/GLM-01_0/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '1' & fMRI_HED$time == 1 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/HED/GLM-01_1/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '-1' & fMRI_HED$time == 1 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/HED/GLM-01_1/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_HED)[colnames(fMRI_HED) == 'id'] <- 'Subj'

fMRI_HED[is.na(fMRI_HED)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/HED/'
write.table(fMRI_HED, (file.path(path, "HED_LME_withcov.txt")), row.names = F, sep="\t")


# INPUT FOR FMRI already lik-------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_HED = df

IDX = unique(fMRI_HED$id)
init <- 1:length(fMRI_HED$id)
fMRI_HED$InputFile = init
for(i in 1:length(IDX)){
  fMRI_HED$InputFile[fMRI_HED$condition == '1' & fMRI_HED$time == 0 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/HED/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '-1' & fMRI_HED$time == 0 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/HED/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '1' & fMRI_HED$time == 1 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/HED/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_HED$InputFile[fMRI_HED$condition == '-1' & fMRI_HED$time == 1 & fMRI_HED$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/HED/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_HED)[colnames(fMRI_HED) == 'id'] <- 'Subj'

fMRI_HED[is.na(fMRI_HED)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/HED/GLM-01'
write.table(fMRI_HED, (file.path(path, "HED_LME_withcov.txt")), row.names = F, sep="\t")

for id in  202 203 204 209 213 217 220 224 225 235 236 237 238 239 241 246 250 259 264 265 266 269 270
do
mv *${id}* placebo/
done
mv sub* treatment/