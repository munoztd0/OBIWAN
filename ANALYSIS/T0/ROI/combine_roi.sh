#!/bin/bash
home=$(eval echo ~$user);

#codeDir="${home}/REWOD/DERIVATIVES/PREPROC/CANONICALS/"
codeDir="${home}/REWOD/EXTERNALDATA/ROI/"
echo ${codeDir}
cd ${codeDir}

#fslmaths Pirif_Left.nii -add Pirif_Right.nii combined_piri.nii
#fslmaths prob_frontal.nii -add prob_OFC.nii combined_OFC

fslmaths combined_OFC.nii -mas ~/REWOD/DERIVATIVES/ANALYSIS/hedonic/GLM-04/group/covariate/Reward_NoReward_lik_meancent/removing-24/Reward-NoReward/mask.nii masked_OFC
fslmaths caud0.5 -mas head.nii caud_head
fslmaths put0.5 -mas head.nii put_head
#fslmaths dlPFC_LEFT.nii -add dlPFC_RIGHT.nii combined_dlPFC.nii

#fslmaths FRONTAL_LEFT.nii -add FRONTAL_RIGHT.nii combined_FRONTAL.nii

#fslmaths OFC_LEFT.nii -add OFC_RIGHT.nii combined_OFC.nii

#fslmaths pINS_LEFT.nii -add pINS_RIGHT.nii combined_pINS.nii

#fslmaths SUBCAL_LEFT.nii -add SUBCAL_RIGHT.nii combined_SUBCAL.nii

#fslmaths vmPFC_LEFT.nii -add vmPFC_RIGHT.nii combined_vmPFC.nii

#mkdir ROIs

gunzip*

#mv *combined /ROIs
