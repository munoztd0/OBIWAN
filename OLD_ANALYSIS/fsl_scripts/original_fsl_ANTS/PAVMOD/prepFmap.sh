#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
sessionID=$2
taskID=$3
#subjectID="control125"
#sessionID="second"
#taskID="PIT"

echo "Preparing subject ${subjectID}: session ${sessionID} for FEAT"

# directory containing fsl scripts and templates
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/FSL_ANTS/
# Directory containing nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/
# Output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/

# make the subject level directory
mkdir -p ${outDir}fmap

# Fieldmap generation for SIEMENS data
# expects a phase image, a magnitude image (brain extracted) and an echo time difference
# prepares a fieldmap suitable for FEAT for SIEMENS data - saves output in rad/s format
echo "started building fieldmaps for session ${sessionID}: task ${tasID} at $(date +"%T")"
# reorient the mag and phasediff
fslreorient2std ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1 ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_reoriented
fslreorient2std ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff_reoriented
# brain extract the magnitude image
bet ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1.nii.gz ${outDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain1 -f 0.5 -R
# erode the brain-extracted magnitude image once for a tight mask (recommended)
fslmaths ${outDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain1 -ero ${outDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain
# create fieldmap
fsl_prepare_fieldmap SIEMENS ${dataDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff.nii.gz ${outDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain ${outDir}fmap/sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_fmap_rads 2.65
echo "Done building fieldmaps for session ${sessionID}: task ${taskID} at $(date +"%T")"
