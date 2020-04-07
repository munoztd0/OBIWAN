#!/bin/bash
home=$(eval echo ~$user);

#codeDir="${home}/REWOD/DERIVATIVES/PREPROC/CANONICALS/"
codeDir="${home}/REWOD/DERIVATIVES/ANALYSIS/CONN/ROI"

echo ${codeDir}
cd ${codeDir}

#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 0.9 -uthr 1.1 -bin AMY_BLN_La.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 1.9 -uthr 2.1 -bin AMY_BLN_BLDI.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 2.9 -uthr 3.1 -bin AMY_BLN_BM.nii
#fslmaths CIT168_dCEN_1mm_MNI.nii -bin AMY_CEN.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 4.9 -uthr 5.1 -bin AMY_CMN.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 5.9 -uthr 6.1 -bin AMY_BLVP.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 6.9 -uthr 7.1 -bin AMY_ASTA.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 7.9 -uthr 8.1 -bin AMY_ATA.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 8.9 -uthr 9.1 -bin AMY_AAA.nii
#fslmaths CIT168_iAmyNuc_1mm_MNI.nii -thr 9.9 -uthr 10.1 -bin AMY_other.nii

#fslmaths harvardoxford-subcortical_prob_Left_Accumbens.nii -bin Left_NAcc_harvard

fslmaths prob_Right_Putamen.nii -thr 50 -bin Put_R.nii
#fslmaths harvardoxford-cortical_prob_vmPFC.nii -thr 50 -bin prob_vmPFC
#fslmaths pcore_shell_LEFT -thr 2 -bin pshell_LEFT
#Fslmaths pcore_shell_RIGHT -thr 1 -uthr 1.9 -bin pcore_RIGHT
#fslmaths pcore_shell_RIGHT -thr 2  -bin pshell_RIGHT

gunzip Caud*
gunzip Put*
