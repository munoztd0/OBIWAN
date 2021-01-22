if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr, car, misty)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)


load('PAV.RData')

PAV = PAV %>% filter(id %notin% c(122, 232)) #missing mri

bs = ddply(PAV, .(id, condition, group, gender), summarise, RT = mean(RT, na.rm = TRUE))
bs$RT = scale(bs$RT)
cov = PAV %>% group_by(id) %>% summarise_if(is.numeric, mean)
cov = select(cov, c(id, ageC, likC, bmiC, diff_bmiC, hungryC, thirstyC, pissC))

# COVARIATE ------------------------------------------------------------------

CSp_RT_con = subset(bs, group == '-1' & condition == 1)
CSp_RT_obe = subset(bs, group == '1'& condition == 1)
CSm_RT_con = subset(bs, group == '-1' & condition == -1)
CSm_RT_obe = subset(bs, group == '1'& condition == -1)


path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/pav/GLM-01_HW'
write.table(CSp_RT_con, (file.path(path, "CSp_RT.txt")), row.names = F, sep="\t")
write.table(CSm_RT_con, (file.path(path, "CSm_RT.txt")), row.names = F, sep="\t")
path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/pav/GLM-01_OB'
write.table(CSp_RT_obe, (file.path(path, "CSp_RT.txt")), row.names = F, sep="\t")
write.table(CSm_RT_obe, (file.path(path, "CSm_RT.txt")), row.names = F, sep="\t")

# INPUT FOR FMRI -------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_PAV = df

IDX = unique(fMRI_PAV$id)
init <- 1:length(fMRI_PAV$id)
fMRI_PAV$InputFile = init
for(i in 1:length(IDX)){
  fMRI_PAV$InputFile[fMRI_PAV$condition == '1' & fMRI_PAV$time == 0 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PAV/GLM-01_0/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '-1' & fMRI_PAV$time == 0 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PAV/GLM-01_0/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '1' & fMRI_PAV$time == 1 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PAV/GLM-01_1/group/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '-1' & fMRI_PAV$time == 1 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/PAV/GLM-01_1/group/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_PAV)[colnames(fMRI_PAV) == 'id'] <- 'Subj'

fMRI_PAV[is.na(fMRI_PAV)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/'
write.table(fMRI_PAV, (file.path(path, "PAV_LME_withcov.txt")), row.names = F, sep="\t")


# INPUT FOR FMRI already RT-------------------------------------------------------------------
df = merge(bs, cov, by = "id")

fMRI_PAV = df

IDX = unique(fMRI_PAV$id)
init <- 1:length(fMRI_PAV$id)
fMRI_PAV$InputFile = init
for(i in 1:length(IDX)){
  fMRI_PAV$InputFile[fMRI_PAV$condition == '1' & fMRI_PAV$time == 0 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '-1' & fMRI_PAV$time == 0 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/GLM-01_0/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '1' & fMRI_PAV$time == 1 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0001.nii', sep ='')
  fMRI_PAV$InputFile[fMRI_PAV$condition == '-1' & fMRI_PAV$time == 1 & fMRI_PAV$id == IDX[i]] <- paste('/home/davidM/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/GLM-01_1/group/cov/sub-obese',IDX[i],'_con-0002.nii', sep ='')
}
colnames(fMRI_PAV)[colnames(fMRI_PAV) == 'id'] <- 'Subj'

fMRI_PAV[is.na(fMRI_PAV)] <- 0

path <-'~/OBIWAN/DERIVATIVES/GLM/AFNI/PAV/GLM-01'
write.table(fMRI_PAV, (file.path(path, "PAV_LME_withcov.txt")), row.names = F, sep="\t")

for id in  202 203 204 209 213 217 220 224 225 234  235 236 237 238 239 241 246 250 259 264 265 269 270
do
mv *${id}* placebo/
  done

mv sub* treatment/
  