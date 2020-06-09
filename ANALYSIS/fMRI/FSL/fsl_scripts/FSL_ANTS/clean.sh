#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
runID=$2

echo "Preparing subject ${subjectID} session ${runID}"

# the subject directory
subT2=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T2_reoriented_brain.nii.gz
# standardT2=/home/jcockburn/casino_fMRI/fMRI_PreProcessing/ICA_ANTs/CIT168_T2w_MNI_lowres
# Directory containing functionals, high-res reference scans, and field-maps
funcDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}.ica/
# Directory with run-specific files
runDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/
# the component classification rejection threshold
threshold=20


###################
# classify components as artifact/signal, remove artifacts
# generates filtered_func_data_clean in the ICA directory
echo "started classification at $(date +"%T")"
# the classifier path
classifierPath=/home/shared/fix/classifiers/FIX_giovanniCoins_jeffCasinoUSA.RData
# classify components (approx 30 min)
# will generate a label file at the specified threshold called fix4melview_FIX_giovanniCoins_jeffCasinoUSA_thr<threshold>.txt
/usr/local/fix/fix -c ${funcDir} ${classifierPath} ${threshold}
echo "Classification done at $(date +"%T")"
# remove bad ones (using the manually corrected classification) and filters out movement (flag -m)
# /usr/local/fix/fix -a ${funcDir}fix4melview_FIX_giovanniCoins_jeffCasinoUSA_thr${threshold}.txt -m
/usr/local/fix/fix -a ${funcDir}fix_modified_thr${threshold}.txt -m
echo "finished cleanup at $(date +"%T")"
