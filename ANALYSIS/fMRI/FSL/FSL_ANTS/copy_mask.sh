#!/bin/bash



# WOORK IN PROGRESS

# pull in the subject we should be working on
# subjectID=$1


# I want this to be as slow and discrete as possible so we do it sequentially

# --------------------- copy mask subject T1 and T2 ----------------------------
for subjectID in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do

    maskT1=evapool@tolman.caltech.edu:/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T1_reoriented_brain_mask.nii.gz # copy from tolman
    maskT2=evapool@tolman.caltech.edu:/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T2_reoriented_brain_mask.nii.gz # copy from tolman
    outT1=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/anat/sub-${subjectID}_T1w_mask.nii.gz # copy to cisacalc
    outT2=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/anat/sub-${subjectID}_T2w_mask.nii.gz # copy to cisacalc

    # copy T1
    echo "Copying T1 mask Subject ${subjectID}  at $(date +"%T")"
    sshpass -p 'Rimerli2' scp -l 2000 ${maskT1} ${outT1}
    echo "Finish copying T1 mask Subject ${subjectID} at $(date +"%T")"

    echo "Copying T2 mask Subject ${subjectID}  at $(date +"%T")"
    sshpass -p 'Rimerli2' scp -l 2000 ${maskT2} ${outT2}
    echo "Finish copying T2 mask Subject ${subjectID} at $(date +"%T")"

   # copy T2

done
