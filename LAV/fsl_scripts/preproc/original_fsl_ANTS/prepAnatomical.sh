#!/bin/bash

# ID for the subject we're working
subjectID=$1
#subjectID="control102"
echo "Preparing subject ${subjectID} for FEAT"

# Directory containing un-processed nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/
# Output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/

# make the subject level directory
mkdir -p ${outDir}

# about 15 min 

# ###################
# T1 SCAN: Reorient and extract brain
# Expects a file called T1 in the source directory
echo "Started working on T1 scan at $(date +"%T")"
# Reorient T1 scan to standard, and extract brain
fslreorient2std ${dataDir}ses-first/anat/*T1.nii.gz ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented
bet ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain -f 0.2 -B
#bet ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain -f 0.2 -g -0.4 -c 98 107 65
echo "Done working on T1 scan at $(date +"%T")"

# ###################
# T2 SCAN: Reorient and extract brain
# Expects a file called T2 in the source directory
echo "Started working on T2 scan at $(date +"%T")"
# Reorient T2 scan to standard, and extract brain
fslreorient2std ${dataDir}ses-first/anat/*T2.nii.gz ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented
bet ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented_brain -f 0.2 -B
echo "Done working on T2 scan at $(date +"%T")"
