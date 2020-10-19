#!/bin/bash

# pull in the subject we should be working on
subjID=$1

#anatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjID}/ses-first/anat/
#outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjID}/
anatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ANTS/sub-${subjID}/ses-first/anat/
outDir=/home/OBIWAN/DATA/STUDY/CLEAN_ANTS/sub-${subjID}/

T1Image=sub-${subjID}_ses-first_run-01_T1_reoriented_brain_ANTsCoreg.nii.gz
T2Image=sub-${subjID}_ses-first_run-01_T2_reoriented_brain_ANTsCoreg.nii.gz

mkdir -p ${outDir}ses-first/anat/

# copy ANTsed anatomical images to clean directory
echo "Copying anatomical images to output directory at $(date +"%T")"
cp -v ${anatDir}${T1Image} ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T1.nii.gz
cp -v ${anatDir}${T2Image} ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T2.nii.gz

# unzip for use in SPM
echo "Expanding anatomical images for Subject ${subjID} at $(date +"%T")"
gunzip -f ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T1.nii.gz
gunzip -f ${outDir}ses-first/anat/sub-${subjID}_ses-first_acq-ANTnorm_T2.nii.gz
echo "Done expanding anatomical images for Subject ${subjID} at $(date +"%T")"
