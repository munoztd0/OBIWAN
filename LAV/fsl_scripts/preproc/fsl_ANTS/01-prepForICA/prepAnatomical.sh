#!/bin/bash

# pull in subject we're working on
subjectID=$1

echo "Preparing subject ${subjectID}, first session, for FEAT"

# directory containing raw nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/
# output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/

# make subject level directory
mkdir -p ${outDir}

####################
# T1: reorient and extract brain
# expects a file called T1 in the source directory

echo "Started reorientation and brain extraction on T1 at $(date +"%T")"

# reorient T1 to standard
fslreorient2std ${dataDir}ses-first/anat/*T1.nii.gz ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented

# extract brain (default -f threshold 0.2, if standard -B flag isn't satisfactory try combination of -f XX -g XX -c XXX XXX XXX or use T2 brain mask)
bet ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain -f 0.2 -B
# bet ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain -f 0.3 -g -0.2 -c 96 119 165 -m
# fslmaths ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented -mas ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented_brain_mask ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain

echo "Done reorientation and brain extraction on T1 at $(date +"%T")"

###################
# T2: reorient and extract brain
# expects a file called T2 in the source directory

echo "Started reorientation and brain extraction on T2 at $(date +"%T")"

# reorient T2 to standard
fslreorient2std ${dataDir}ses-first/anat/*T2.nii.gz ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented

# extract brain (default -f threshold 0.2, if standard -B flag isn't satisfactory try combination of -f XX -g XX -c XXX XXX XXX or use T1 brain mask)
bet ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented_brain -f 0.2 -B
# bet ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented_brain -f 0.4 -g -0.0 -c 96 115 169 -m
# fslmaths ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented -mas ${outDir}sub-${subjectID}_ses-first_run-01_T1_reoriented_brain_mask ${outDir}sub-${subjectID}_ses-first_run-01_T2_reoriented_brain

echo "Done reorientation and brain extraction on T2 at $(date +"%T")"

echo "Done preparing subject ${subjectID}, first session, for FEAT"
