#!/bin/bash

# pull in the subject we're working on
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

echo "Preparing subject ${subjectID}, ${sessionID} session functionals, for FEAT"

# directory containing raw nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/func/
# output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/

# make subject level directory
mkdir -p ${outDir}

###################
# functional data: reorient and extract brain
# generates sub-<subjectID>_ses-<sessionID>_task-<taskID>_run-01_bold_reoriented_brain

echo "Started reorientation and brain extraction on functionals for ${sessionID} session, ${taskID} task, at $(date +"%T")"

# reorient functionals to standard
fslreorient2std ${dataDir}*task-${taskID}_run-01_bold.nii.gz ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented

# extract brain (order of flags matters for bet; -F applies bet to whole series; default threshold 0.25)
bet ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain -R -F -f 0.3
# bet ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain -R -F -f 0.4

echo "Done reorientation and brain extraction on functionals for ${sessionID} session, ${taskID} task, at $(date +"%T")"

echo "Done preparing subject ${subjectID}, ${sessionID} session functionals, for FEAT"
