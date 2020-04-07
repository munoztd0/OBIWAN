#!/bin/bash

# pull in the subject we should be working on
subjectID=$1

#choose task OR runID=$2
taskID=$2


home=$(eval echo ~$user)
#generates bold_reoriented_brain & fmap_rads + fmap_mag
echo "Preparing subject ${subjectID} for FEAT"

# Directory containing nifti data
dataDir=${home}/REWOD/sub-${subjectID}/ses-second/

# Output directory for preprocessed files
outDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/

# make the subject level directory
mkdir -p ${outDir}func
mkdir -p ${outDir}fmap



###################
# functional data // generates <taskID>_reoriented_brain

echo "Started reorientation on functional scans for task ${taskID} at $(date +"%T")"
# reorient brain
fslreorient2std ${dataDir}func/sub-${subjectID}_ses-second_task-${taskID}_run-01_bold.nii.gz ${outDir}func/sub-${subjectID}_ses-second_task-${taskID}_run-01_bold_reoriented.nii.gz

# extract brain // normal threshold = 0.25 but we adujsted it to 0.2 (or smaller depending on participant) // whatch out the order of flags is important
bet ${outDir}func/sub-${subjectID}_ses-second_task-${taskID}_run-01_bold_reoriented.nii.gz ${outDir}func/sub-${subjectID}_ses-second_task-${taskID}_run-01_bold_reoriented_brain.nii.gz -R -F -f 0.2

echo "Done reorientation and extraction on functional for task ${taskID} at $(date +"%T")"



###################
# Fieldmap generation for SIEMENS data // takes 5-10 min
# expects a phase image, a magnitude image (brain extracted) and an echo time difference
# prepares a fieldmap suitable for FEAT for SIEMENS data - saves output in rad/s format
echo "started building fieldmaps for session second: task  at $(date +"%T")"

# reorient the mag and phasediff
fslreorient2std ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_reoriented
fslreorient2std ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_phasediff ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_phasediff_reoriented

# brain extract the magnitude image // bet need to be tight!
bet ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_reoriented.nii.gz ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_brain -f 0.5 -R

# erode the brain-extracted magnitude image once for a tight mask (recommended) :  Erode by zeroing non-zero voxels when zero voxels found in kernel
fslmaths ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_brain -ero ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_mag

# create fieldmap & convert angle to rads/second (*2.46)
fsl_prepare_fieldmap SIEMENS ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_phasediff.nii.gz ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_mag ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_rads 2.46

#clean useless
rm ${outDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_brain.nii.gz
rm ${dataDir}fmap/sub-${subjectID}_ses-second_run-01_fmap_magnitude_ro*

echo "Done building fieldmaps for session second: task  at $(date +"%T")"
