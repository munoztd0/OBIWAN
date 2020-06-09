#!/bin/bash

# pull in the subject we should be working on
# subjectID=$1
# sessionID=$2

# I want this to be as slow and discrete as possible so we do it sequentially

for subjectID in 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
  for sessionID in 01 02 03
  do
    funcDir=evapool@tolman.caltech.edu:/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${sessionID}.ica/ # copy from tolman
    outDir=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/func # copy to cisacalc
    funcImage=filtered_func_data_clean_unwarped_Coreg.nii.gz

    echo "Copying unsmoothed Subject ${subjectID} Run ${sessionID} at $(date +"%T")"
    sshpass -p 'Rimerli2' scp -l 2000 ${funcDir}${funcImage} ${outDir}/sub-${subjectID}_task-Pavmod_run-${sessionID}_nosmoothBold.nii.gz
    echo "Finish copying Subject ${subjectID} Run ${sessionID} at $(date +"%T")"
  done
done
