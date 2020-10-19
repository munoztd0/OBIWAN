#!/bin/bash

# pull in subject
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

echo "Preparing FIX training data for subject ${subjectID}, session ${sessionID}, task ${taskID}"

# input MELODIC directory
melodicDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/

# output FIX training data directory
trainDir=/home/shared/fix/data/OBIWAN/sub-${subjectID}/task-${taskID}/

# classifier name
classifierName=obiwan_02

# component classification rejection threshold
threshold=20

# make output FIX training data directory
mkdir -p ${trainDir}

###################
# copy MELODIC directory to FIX training data directory
echo "Copying MELODIC directory to FIX training data directory for subject ${subjectID}, session ${sessionID}, task ${taskID}"

cp -r ${melodicDir} ${trainDir}

# rename output FIX training data directory
mv ${trainDir}task-${taskID}.ica/ ${trainDir}melodic_run.ica/

echo "Done copying MELODIC directory to FIX training data directory for subject ${subjectID}, session ${sessionID}, task ${taskID}"

# rename manual classification in FIX training data directory to 'hand_labels_noise.txt' expected by FIX
echo "Renaming manual classification for subject ${subjectID}, session ${sessionID}, task ${taskID}"

cp -v ${trainDir}melodic_run.ica/fix_modified_${classifierName}_thr${threshold}.txt ${trainDir}melodic_run.ica/hand_labels_noise.txt

echo "Done renaming manual classification for subject ${subjectID}, session ${sessionID}, task ${taskID}"


echo "Done preparing FIX training data for subject ${subjectID}, session ${sessionID}, task ${taskID}"
