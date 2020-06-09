#!/bin/bash

# create individual whole brain masks


popAnat=/home/eva/PAVMOD/DATA/brain/CANONICALS/averaged_T1w.nii
popMask=/home/eva/PAVMOD/DATA/brain/CANONICALS/averaged_T1w_mask.nii

# construct the mask
fslmaths $popAnat -thr .1 -bin $popMask

# unzip for use in SPM
echo "Expanding Subject ${sbjID} at $(date +"%T")"
gunzip -f $popMask
