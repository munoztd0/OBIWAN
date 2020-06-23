#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
sessionID=$2
taskID=$3
#subjectID="control125"
#sessionID="second"
#taskID="pavlovianlearning"
echo "Preparing subject ${subjectID}: session ${sessionID} for FEAT"

# directory containing fsl scripts and templates
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/FSL_ANTS/
# Directory containing nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/
# Output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/

# make the subject level directory
mkdir -p ${outDir}func

###################
# functional data
# reorient and extract brain
# generates Session<runID>_reoriented_brain
echo "Started reorientation on functional scans for session ${sessionID}: task ${taskID} at $(date +"%T")"
fslreorient2std ${dataDir}func/*task-${taskID}_run-01_bold.nii.gz ${outDir}func/sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented
# order of flags matters for bet (-F applies bet to whole series)
bet ${outDir}func/sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented ${outDir}func/sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain -R -F -f 0.25
echo "Done reorientation and extraction on functional for session ${sessionID}: task ${taskID} at $(date +"%T")"
