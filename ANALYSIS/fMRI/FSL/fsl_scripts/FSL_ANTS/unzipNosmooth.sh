#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
sessionID=$2

outDir=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/


# unzip for use in SPM
echo "Expanding Subject ${subjectID} Session ${sessionID} at $(date +"%T")"
gunzip -f ${outDir}func/sub-${subjectID}_task-Pavmod_run-${sessionID}_nosmoothBold.nii.gz
echo "Done expanding Subject ${subjectID} Session ${sessionID} at $(date +"%T")"
