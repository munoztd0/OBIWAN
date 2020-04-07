#!/bin/bash
home=$(eval echo ~$user)

#small function to move and copy files
subjID=$1
group=$2

source ~/anaconda3/etc/profile.d/conda.sh 
conda activate NEW


#for subjID in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
  #do
  #for taskID in hedonic PIT
    #do
#1mkdir -p ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat
#1cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-first/anat/*.json ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/
#mkdir -p ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/func/*.json ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/func/*.tsv ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
#sub-${group}${subjID}_ses-second_acq-task-hedonicreactivity_magnitude1.nii.gz
#sub-${group}${subjID}_ses-second_run-01_magnitude.nii.gz
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-first/anat/*.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/
#pydeface  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T1.nii.gz
#pydeface  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T2.nii.gz
rm  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T1.nii.gz
rm  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T2.nii.gz
mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T1_defaced.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T1w.nii.gz
mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T2_defaced.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T2w.nii.gz





    #done
 #done
