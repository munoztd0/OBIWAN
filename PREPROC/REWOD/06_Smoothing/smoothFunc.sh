#!/bin/bash

# pull in the subject we should be working on
subjID=$1

#choose task OR runID=$2
taskID=$2

home=$(eval echo ~$user)

#new directory with final preprocesssed bold files
outDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/
funcImage=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/task-${taskID}.ica/filtered_func_data_clean_unwarped_Coreg
echo ${outDir}
echo ${funcImage}
#FWHM = sigma*sqrt(8*ln(2))!
smoothKern=1.69865806013 # to smooth 4 mm
#echo ${smoothKern}

echo "Smoothing Subject ${subjID} Session  at $(date +"%T")"

#kernel gauss takes the sigma (not the pixel FWHM) = sigma*2.3548
# and I'm calling off the ses-second from now on
fslmaths ${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}sub-${subjID}_task-${taskID}_run-01_smoothBold


# unzip for use in SPM
echo "Expanding Subject ${subjID} Session 2 at $(date +"%T")"
gunzip -f ${outDir}sub-${subjID}_task-${taskID}_run-01_smoothBold.nii.gz
echo "Done expanding Subject ${subjID}  at $(date +"%T")"
