#!/bin/bash

# pull in the subject we should be working on
subjectID=$1

#choose task OR runID=$2
taskID=$2

##echo "Preparing subject ${subjectID} session ${taskID}"
echo "Preparing subject ${subjectID} task ${taskID}"

home=$(eval echo ~$user)

# Directory containing prepped nifti data
dataDir=${home}/REWOD/sub-${subjectID}/ses-second/func/

# Output directory for preprocessed files
outDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/func/


###########################
# task MELODIC template: approx 10 hours for 400 volumns
echo "Started MELODIC for task ${taskID} at $(date +"%T")"

# create a template name for subject and task
melodicTempplate=${outDir}ICA_sub-${subjectID}_ses-second_task-${taskID}.fsf

# move the template into the task directory
cp ${codeDir}ICA.fsf $melodicTempplate

# carve in subject specific numbers using wildcards
sed -i -e 's/subXXX/'$subjectID'/g' $melodicTempplate

# carve in task specific numbers using wildcards
sed -i -e 's/RUNYYY/'$taskID'/g' $melodicTempplate


# carve in nvols specific numbers using wildcards
nvols=`fslnvols ${dataDir}*task-${taskID}_run-01_bold.nii.gz`
sed -i -e 's/ZZZ/'$nvols'/' $melodicTempplate
echo ${nvols}

# carve in nvoxs specific numbers using wildcards
# firt output is <voxels> second is <volumes>, this just takes the first input
arr=`fslstats ${dataDir}*task-${taskID}_run-01_bold.nii.gz -v`
nvoxs=$(echo ${arr} | cut -d " " -f 1)
sed -i -e 's/WWW/'$nvoxs'/' $melodicTempplate
echo ${nvoxs}

# task the template into FEAT
feat $melodicTempplate

echo "Finished MELODIC for task ${taskID} at $(date +"%T")"
