#!/bin/bash

# pull in subject
subjectID=$1

# pull in session
sessionID=$2

# pull in task
taskID=$3

echo "Preparing subject ${subjectID}, session ${sessionID}, task ${taskID} for classification"

# T2 scan
subT2=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/*T2_reoriented_brain.nii.gz

# directory containing functionals (MELODIC output directory)
funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/

# directory with run-specific files
runDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/

# classifier name
classifierName=obiwan_03

# path to classifier
classifierPath=/home/shared/fix/classifiers/FIX_${classifierName}.RData

# component classification rejection threshold
threshold=20


###################
# classify components as artifact/signal

echo "Started classification for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

# classify components (-c flag, about 5-30 min): generates a label file at specified threshold called fix4melview_FIX_<classifierName>_thr<threshold>.txt
/usr/local/fix1.066/fix -c ${funcDir} ${classifierPath} ${threshold}

echo "Classification for subject ${subjectID}, session ${sessionID}, task ${taskID} done at $(date +"%T")"


# ###################
# # cleanup: remove noise
# # generates filtered_func_data_clean in the ICA directory

#echo "Started cleanup for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

# remove noise (-a flag) using raw classifier classification and filter out movement (-m flag)
#here # /usr/local/fix1.066/fix -a ${funcDir}fix4melview_FIX_${classifierName}_thr${threshold}.txt -m

# OR

# remove noise (-a flag) using manually corrected classification and filter out movement (-m flag)
#/usr/local/fix1.066/fix -a ${funcDir}fix_modified_${classifierName}_thr${threshold}.txt -m

# OR

# for training data: remove noise (-a flag) using original manual classification and filter out movement (-m flag)
# /usr/local/fix1.066/fix -a ${funcDir}hand_labels_noise.txt -m
# /usr/local/fix1.066/fix -a ${funcDir}hand_labels_noise_lavinia.txt -m


echo "Finished cleanup for subject ${subjectID}, session ${sessionID}, task ${taskID} $(date +"%T")"
