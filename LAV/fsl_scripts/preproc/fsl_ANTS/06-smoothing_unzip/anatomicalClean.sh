#!/bin/bash

# pull in subject
subjectID=$1

# input directory containing anatomical data
anatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/

# output directory for preprocessed data
outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjectID}/ses-first/anat/
anatDav=/home/OBIWAN/DERIVATIVES/PREPROC/sub-${subjectID}/ses-first/anat/


# make subject level directory
mkdir -p ${outDir}
mkdir -p ${anatDav}

T1Image=sub-${subjectID}_ses-first_run-01_T1_reoriented_brain_ANTsCoreg.nii.gz
T2Image=sub-${subjectID}_ses-first_run-01_T2_reoriented_brain_ANTsCoreg.nii.gz

###################
# copy ANTsed anatomical images to CLEAN directory
echo "Copying anatomicals for subject ${subjectID} to output directory at $(date +"%T")"

cp ${anatDir}${T1Image} ${outDir}sub-${subjectID}_ses-first_acq-ANTsNorm_T1w.nii.gz
cp ${anatDir}${T2Image} ${outDir}sub-${subjectID}_ses-first_acq-ANTsNorm_T2w.nii.gz

cp ${anatDir}${T1Image} ${anatDav}sub-${subjectID}_ses-first_acq-ANTsNorm_T1w.nii.gz
cp ${anatDir}${T2Image} ${anatDav}sub-${subjectID}_ses-first_acq-ANTsNorm_T2w.nii.gz

echo "Done copying anatomicals for subject ${subjectID} to output directory at $(date +"%T")"


# unzip for use in SPM
echo "Expanding anatomicals for subject ${subjectID} at $(date +"%T")"

gunzip -f ${outDir}sub-${subjectID}_ses-first_acq-ANTsNorm_T1w.nii.gz
gunzip -f ${outDir}sub-${subjectID}_ses-first_acq-ANTsNorm_T2w.nii.gz

gunzip -f ${anatDav}sub-${subjectID}_ses-first_acq-ANTsNorm_T1w.nii.gz
gunzip -f ${anatDav}sub-${subjectID}_ses-first_acq-ANTsNorm_T2w.nii.gz

echo "Done expanding anatomicals for subject ${subjectID} at $(date +"%T")"
