#!/bin/bash

# ID for the subject we're working
subjectID=$1
echo "Preparing subject ${subjectID} for FEAT"

# Directory containing un-processed nifti data
dataDir=/home/evapool/PAVMOD/DATA/brain/population/${subjectID}/
# Output directory for preprocessed files
outDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/

# make the subject level directory
mkdir ${outDir}

# ###################
# T1 SCAN: Reorient and extract brain
# Expects a file called T1 in the source directory
echo "Started working on T1 scan at $(date +"%T")"
# Reorient T1 scan to standard, and extract brain
fslreorient2std ${dataDir}T1_comb_norm/NIFTI/*nii.gz ${outDir}T1_reoriented
bet ${outDir}T1_reoriented ${outDir}T1_reoriented_brain -f 0.25 -B
echo "Done working on T1 scan at $(date +"%T")"


# ###################
# T2 SCAN: Reorient and extract brain
# Expects a file called T2 in the source directory
echo "Started working on T2 scan at $(date +"%T")"
# Reorient T2 scan to standard, and extract brain
fslreorient2std ${dataDir}T2_norm/NIFTI/*nii.gz ${outDir}T2_reoriented
bet ${outDir}T2_reoriented ${outDir}T2_reoriented_brain -f 0.25 -B
echo "Done working on T2 scan at $(date +"%T")"
