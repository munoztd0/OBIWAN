#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
sessionID=$2


funcDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${sessionID}.ica/
outDir=/home/evapool/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/
funcImage=filtered_func_data_clean_unwarped_Coreg
smoothKern=3.39731612 # to smooth 8 mm

mkdir ${outDir}
mkdir ${outDir}/func

echo "Smoothing Subject ${subjectID} Session ${sessionID} at $(date +"%T")"
fslmaths ${funcDir}${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}func/sub-${subjectID}_task-Pavmod_run-${sessionID}_smoothBold
echo "Smoothing Subject ${subjectID} Session ${sessionID} at $(date +"%T")"

# unzip for use in SPM
echo "Expanding Subject ${subjectID} Session ${sessionID} at $(date +"%T")"
gunzip -f ${outDir}func/sub-${subjectID}_task-Pavmod_run-${sessionID}_smoothBold.nii.gz
echo "Done expanding Subject ${subjectID} Session ${sessionID} at $(date +"%T")"
