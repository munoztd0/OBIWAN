#!/bin/bash

# pull in the subject we should be working on
subjID=$1
sessionID=$2
taskID=$3


#funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjID}/ses-${sessionID}/func/task-${taskID}.ica/
funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ANTS/sub-${subjID}/ses-${sessionID}/func/
#anatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjID}/ses-first/anat/
#outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjID}/
outDir=/home/OBIWAN/DATA/STUDY/CLEAN_ANTS/sub-${subjID}/

#funcImage=filtered_func_data_clean_unwarped_Coreg
funcImage=sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain_unwarped_Coreg
#T1Image=sub-${subjID}_ses-first_run-01_T1_reoriented_brain_ANTsCoreg.nii.gz
#T2Image=sub-${subjID}_ses-first_run-01_T2_reoriented_brain_ANTsCoreg.nii.gz
smoothKern=3.39731612 # to smooth 8 mm
#soooooo FWHM = sigma*sqrt(8*ln(2))
#smoothKern=1.69865806013 # to smooth 4 mm

#mkdir -p ${outDir}ses-first/anat/
mkdir -p ${outDir}ses-${sessionID}/func/

echo "Smoothing Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"
#kernel gauss takes the sigma (not the pixel FWHM) = sigma*2.3548
fslmaths ${funcDir}${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}ses-${sessionID}/func/sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_smoothBold

# copy ANTsed anatomical images to clean directory
#echo "Copying anatomical images to output directory at $(date +"%T")"
#cp -v ${anatDir}${T1Image} ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T1.nii.gz
#cp -v ${anatDir}${T2Image} ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T2.nii.gz

# unzip for use in SPM
echo "Expanding functional images for Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"
gunzip -f ${outDir}ses-${sessionID}/func/sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_smoothBold.nii.gz
echo "Done expanding functional images for Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"

#echo "Expanding anatomical images for Subject ${subjID} at $(date +"%T")"
#gunzip -f ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T1.nii.gz
#gunzip -f ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T2.nii.gz
#echo "Done expanding anatomical images for Subject ${subjID} at $(date +"%T")"
