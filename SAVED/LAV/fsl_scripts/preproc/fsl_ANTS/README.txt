1. Preparation for ICA
a) prepAnatomical: Reorients and does brain extraction on anatomicals (default threshold for bet is 0.2).
b) prepFunctional: Reorients and does brain extraction on functionals (default threshold for bet is 0.25, -F flag applies BET to whole series).
c) prepFmap: Reorients magnitude and phasediff images, does brain extraction on magnitude image and creates fieldmap suitable for FEAT (default echo time difference is 2.46).
-> run_prepForICA

2. MELODIC ICA
a) ICA.fsf
b) melodicICA: Runs MELODIC on each functional session to compute the components that will be removed in the next step (this can take a long time depending on the number of volumes and on how noisy the data is, usually 0.5-3 hours). Also does brain extraction on functionals (default threshold is 0.3) unless option is turned off in ICA.fsf (if BET is turned off, set brain/background threshold to 0 and provide alternative mask).
-> run_melodicICA

3. FIX
a) prepForTraining: Copies MELODIC output directory containing manually labeled data to FIX training data directory, and renames manual classifications to 'hand_labels_noise.txt' expected by FIX.
-> run_prepForTraining
b) trainClassifier: Trains classifier using manually labeled data in FIX OBIWAN training data directory. Outputs the classifier (.Rdata) and results of LOO test (indicates which threshold yields best sensitivity/sensibility - usually TPR should be optimized) to the user directory.
-> run_trainClassifier
c) cleanICA: Uses classifier to label components w/ specified threshold and removes noise (using raw classifier classification or manually corrected classification). CAUTION: if MELODIC was run w/o BET, the mask in the MELODIC output directory (task-*) - which is used by fix to create features - will be empty and must be replaced by the mask in filtered_func_data.ica.
-> run_cleanICA
d) classifier_ACC.m: Computes accuracy of classifier compared to hand classification.

4. FUGUE unwarping
a) fmUnwarp: Realigns fieldmaps w/ functionals and uses fieldmaps to unwarp functionals.
-> run_fmUnwarp

5. ANTS coregistration
a) ANTsAnatomicalWarp: Rougly aligns the T2 to the T1 (using FLIRT) and computes the warp into a standard space using ANTs (this takes a looong time), output needed for next step.
-> run_ANTsAnatomical
b) ANTsCoregAnatomical: Uses ANTs to move the T2 into standard space.
c) ANTsCoregRefAndFunc Uses ANTs to move functionals into standard space.
-> run_ANTsCoreg

6. Smoothing and unziping
a) smoothFunctional.sh: Smooths functionals, copies preprocessed functionals to final CLEAN directory and unzips them for use in SPM.
b) anatomicalClean: Copies preprocessed anatomicals to final CLEAN directory and unzips them for use in SPM.
-> run_prepForClean
