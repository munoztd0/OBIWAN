#!/bin/bash

# pull in the subject we should be working on
subjID=$1
sessionID=$2
taskID=$3


funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjID}/ses-${sessionID}/func/task-${taskID}.ica/
anatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjID}/ses-first/anat/
outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjID}/

#funcImage=filtered_func_data_clean_unwarped_Coreg
funcImage=sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain_unwarped_Coreg
smoothKern=3.39731612 # to smooth 8 mm
#smoothKern=1.69865806013 # to smooth 4 mm
#soooooo FWHM = sigma*sqrt(8*ln(2))

#mkdir -p ${outDir}ses-first/anat/
mkdir -p ${outDir}ses-${sessionID}/func/

echo "Smoothing Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"
#kernel gauss takes the sigma (not the pixel FWHM) = sigma*2.3548
fslmaths ${funcDir}${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}ses-${sessionID}/func/sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_smoothBold

# unzip for use in SPM
echo "Expanding functional images for Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"
gunzip -f ${outDir}ses-${sessionID}/func/sub-${subjID}_ses-${sessionID}_task-${taskID}_run-01_smoothBold.nii.gz
echo "Done expanding functional images for Subject ${subjID} Session ${sessionID} Task ${taskID} at $(date +"%T")"
