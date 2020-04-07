#!/bin/bash

ROI_dir=/Users/evapool/mountpoint/PAVMOD/DATA/brain/ROI/GLM-MF-09a/clusters
mask_dir=/Users/evapool/mountpoint/PAVMOD/ANALYSIS/mvpa_scripts/PYmvpa/mvpa_ROI

# loop over ROI
for ROI in VSleftROI
  do
    ROI_in=${ROI_dir}/${ROI}.nii
    ROI_mask=${mask_dir}/${ROI}_mask.nii

    echo "ROI: ${ROI_in} ROI_mask: ${ROI_mask}"

    fslmaths $ROI_in -thr .1 -bin $ROI_mask

done
