3dSeg -anat CIT168_T1w_MNI.nii -mask AUTO -classes 'CSF ; GM ; WM' -bias_classes 'GM ; WM' -bias_fwhm 5 -mixfrac UNI -main_N 5 -blur_meth BIM
3dcalc -a Classes+orig -expr 'equals(a,2)' -prefix maskGM #2 is GM
3dAFNItoNIFTI -prefix maskGM maskGM+orig.HEAD #to nifti

