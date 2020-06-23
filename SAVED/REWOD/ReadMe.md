Folder Stucture in BIDS format
DATA ->  CANONICALS (for standard space)
          STUDY -> DERIVED (for preprocessing) -> ICA_ANTS -> sub-XX -> ses-XXXXX -> anat
                                                                                  -> fmaps
                                                                                  -> func
                -> RAW (untouched raw files)   -> ICA_ANTS -> sub-XX -> ses-XXXXX -> anat
                                                                                  -> fmaps
                                                                                  -> func
                -> CLEAN (after preprocessing is done)
ANALYSIS -> fsl_scripts -> clean_preproc -> (see below)

1) Preparation for FEAT
1.1 PrepFunctional: Reorients and brain extracts all the functional scans (at a choosed threshold) & also creates the fieldmaps reorient them and does the brain extraction (converts from angle to rad/s). These will be needed for the Co-registration.
1.2 PrepAnatomical: Reorients and brain extracts the anatomical & bias corrects, reorients and brain extracts high-res reference image (here single-and ref)
-> run_prepForFEAT

2) MELODIC ICA
2.1 ICA.fsf: melodic template that we adapt to our scan parameters (TR, ET, dwell time, etc..)
2.2 melodICA: create individual ICA template for each subject on each tasks & extracts specific numbers (for nvols, nvoxs, subID and taskID) & Runs melodic on each functional subject and task to compute the components we will remove in the next step (this can take a long time depending on the number of volumes and how noisy the data is).
-> run_melodICA

3) FIX denoising
3.1 Labeling: manually label noise from the filtered_func_data.ica folder and name it "hand_labels_noise.txt" and copy them into the REWODdata folder
3.2 Training classifier: generate a an Rdata file that is the classifier (trained on the present data set) & output a LOO (leave one out) table
& generate a label file at the specified threshold called (fix4melview_FIX_REWOD_thr_XX.txt), then look at them and choose the threshold
-> run_trainFIX
3.3 cleanClass: classify components as artifact/signal, remove artifacts & generates filtered_func_data_clean in the ICA directory
3.4 run_cleanICA: Computes the ICA features and uses the classifier to label & remove bad components (using the manually corrected classification) & filters out movement
-> run_cleanICA

4) FUGUE Unwarping
4.1 fmUnwarp: realigns fieldmaps with functionals and applies it to unwarp reference and functional scans (EPI distortion correction). Fmaps on EPI (& SBref)
->run_FMUnwarp.sh

5) ANTS Coregistration
5.1 ANTsAnatomicalWarp: Roughly aligns the fixed T1 with moving T1 (using flirt), and computes the warp into a standard space using ANTs (this takes a long time!)
-> run_ANTS_Warp_anat
5.2 ANTsCoregAnatomical: Uses ANTs to move anatomical scans into standard space (using xfm1Warp.mat that we computed in last step: Anat Registration)
5.3 ANTsCoregRefAndFunc: Uses ANTs to move functional and Ref scans into standard space
-> run_ANTsCoreg

6) Smoothing
6.1 smoothFunc: Smooths the functional scans, and unzips the compressed image files for use in SPM
-> run_smoothFunctional
