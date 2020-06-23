#!/bin/bash

# pull in subject
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

# input directory containing unsmoothed data
funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/
# output directory for preprocessed data
outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjectID}/ses-${sessionID}/func/
funcDav=/home/OBIWAN/DERIVATIVES/PREPROC/sub-${subjectID}/ses-${sessionID}/func/

# make subject level directories
mkdir -p ${outDir}
mkdir -p ${funcDav}

funcImage=filtered_func_data_clean_unwarped_Coreg.nii.gz

# kernel for smoothing (FWHM = sigma*sqrt(8*ln(2)))
smoothKern=3.39731612 # to smooth 8 mm
# smoothKern=1.69865806013 # to smooth 4 mm

# copy unsmoothed functionals to funcDav
cp ${funcDir}${funcImage} ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_unsmoothedBold.nii.gz

###################
# functional data: smooth and unzip

echo "Smoothing functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

# kernel gauss takes the sigma (not the pixel FWHM) = sigma*2.3548
fslmaths ${funcDir}${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold

# copy smoothed functionals to funcDav
cp ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz  ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

echo "Done smoothing functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"


echo "Expanding functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

# unzip for use in SPM
gunzip -f ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

gunzip -f ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

echo "Done expanding functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"
