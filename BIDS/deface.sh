#!/bin/bash
home=$(eval echo ~$user)
#need to install pydeface first!
for subj in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26;
  do
  pydeface  ${home}/REWOD/sub-${subj}/ses-second/anat/sub-${subj}_ses-second_run-01_T1w.nii.gz
done
