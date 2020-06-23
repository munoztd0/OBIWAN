#!/bin/bash

# pull in subject
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

echo "Preparing subject ${subjectID}, ${sessionID} session, ${taskID} task"

# directory containing scripts and templates
#codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/02-MELODIC_ICA/
codeDir=/home/OBIWAN/CODE/PREPROC/02-MELODIC_ICA/
# directory containing prepped nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/func/
# output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/

mkdir ${outDir}


###########################
# run MELODIC template: approx 4 hours for 960 volumes
echo "Started MELODIC for subject ${subjectID}, ${sessionID} session, ${taskID} task, at $(date +"%T")"

# move the template into the run directory
melodicTempplate=${outDir}ICA_sub-${subjectID}_ses-${sessionID}_task-${taskID}.fsf
cp ${codeDir}ICA.fsf $melodicTempplate

# carve in subject specific numbers
sed -i -e 's/subXXX/'$subjectID'/g' $melodicTempplate
# carve in task specific numbers
sed -i -e 's/RUNYYY/'$taskID'/g' $melodicTempplate
# carve in session specific numbers
sed -i -e 's/sesWWW/'$sessionID'/g' $melodicTempplate

# correct the number of volumes if necessary
nvols=`fslnvols ${dataDir}*task-${taskID}_run-01_bold.nii.gz`
echo ${nvols}
sed -i -e 's/ZZZ/'$nvols'/' $melodicTempplate

# run the template
feat $melodicTempplate

echo "Finished MELODIC for subject ${subjectID}, ${sessionID} session, ${taskID} task at $(date +"%T")"
