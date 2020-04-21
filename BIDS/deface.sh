#!/bin/bash
home=$(eval echo ~$user)/OBIWAN

subjID=$1
group=$2

source ~/anaconda3/etc/profile.d/conda.sh 
conda activate NEW

#need to install pydeface first!

pydeface  ${home}/sub-${group}${subjID}/ses-first/anat/*_T1w.nii.gz
pydeface  ${home}/sub-${group}${subjID}/ses-first/anat/*_T2w.nii.gz

