#!/bin/bash

# create individual whole brain masks

sbjID=$1
echo sbjID: $sbjID

subAnat=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${sbjID}/anat/sub-${sbjID}_acq-ANTnorm_T1w.nii.gz
subMask=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${sbjID}/anat/sub-${sbjID}_T1w_mask.nii.gz

# construct the mask
fslmaths $subAnat -thr .1 -bin $subMask

# unzip for use in SPM
echo "Expanding Subject ${sbjID} at $(date +"%T")"
gunzip -f $subMask
