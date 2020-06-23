#!/bin/bash

# pull in the subject we should be working on
subjectID=$1

echo "Preparing subject ${subjectID} for FEAT"

home=$(eval echo ~$user)
# Directory containing un-processed nifti data
dataDir=${home}/REWOD/sub-${subjectID}/ses-second/
# Output directory for preprocessed files
outDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/

# make the subject level directory
mkdir -p ${outDir}anat/


# ###################
# T1 SCAN: Reorient and extract brain
# Expects a file called T1 in the source directory
echo "Started working on T1 scan at $(date +"%T")"

# Reorient T1 scan to standard
fslreorient2std ${dataDir}/sub-${subjectID}_ses-second_run-01_T1w.nii.gz ${outDir}sub-${subjectID}_ses-second_run-01_T1w_reoriented

# Extract brain
bet ${outDir}sub-${subjectID}_ses-second_run-01_T1w_reoriented ${outDir}sub-${subjectID}_ses-second_run-01_T1w_reoriented_brain -f 0.2 -B
echo "Done working on T1 scan at $(date +"%T")"


###################
# high-res reference image
# generates bias corrected and brain exracted file SBref_reoriented_brain_restore (single band reference image for the session)
echo "Started on reference scan for ${subjectID}  at $(date +"%T")"

# Reorient SBref scan to standard
fslreorient2std ${dataDir}sub-${subjectID}_ses-second_run-01_sbref.nii.gz ${dataDir}sub-${subjectID}_ses-second_run-01_sbref_reoriented

# extract brain from reference scan
bet ${dataDir}sub-${subjectID}_ses-second_run-01_sbref_reoriented ${dataDir}sub-${subjectID}_ses-second_run-01_sbref_reoriented_brain -f 0.25 -R

# bias correct  // output _restore image
fast -n 4 -t 2 -B ${dataDir}sub-${subjectID}_ses-second_run-01_sbref_reoriented_brain

# Delete unnecessary files
rm "${dataDir}"*_seg*
rm "${dataDir}"*_pve*
rm "${dataDir}"*_mixeltype*

echo "Done building reference scan for subj ${subjectID} session second at $(date +"%T")"
