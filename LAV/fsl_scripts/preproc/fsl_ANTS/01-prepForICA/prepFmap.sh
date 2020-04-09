#!/bin/bash

# pull in the subject we're working on
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

echo "Preparing subject ${subjectID}, ${sessionID} session fieldmaps, for FEAT"

# directory containing raw nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/fmap/
# output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/fmap/

# make subject level directory
mkdir -p ${outDir}

###################
# fieldmap generation for SIEMENS data: prepares a fieldmap suitable for FEAT for SIEMENS data - saves output in rad/s format

echo "Started building fieldmaps for ${sessionID} session, ${tasID} task, at $(date +"%T")"

# reorient the magnitude and phasediff images
# fslreorient2std ${dataDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1 ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_reoriented
# fslreorient2std ${dataDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff_reoriented

# brain extract the magnitude image
# bet ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_reoriented.nii.gz ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain1 -f 0.5 -R
bet ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_reoriented.nii.gz ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain1 -f 0.5 -g 0.05 -B

# erode the brain-extracted magnitude image once for a tight mask (recommended)
fslmaths ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain1 -ero ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain

# create fieldmap: fsl_prepare_fieldmap expects a phase image, a magnitude image (brain extracted) and an echo time difference (default is usually 2.46 ms on SIEMENS)
fsl_prepare_fieldmap SIEMENS ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_phasediff_reoriented.nii.gz ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain ${outDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_fmap_rads 2.46

echo "Done building fieldmaps for ${sessionID} session, ${taskID} task, at $(date +"%T")"

echo "Done preparing subject ${subjectID}, ${sessionID} session fieldmaps, for FEAT"
