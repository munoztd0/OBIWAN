#!/bin/bash

# name of classifier
classifierName=FIX_obiwan_03

# directory containing FIX training data
trainDir=/home/shared/fix/data/OBIWAN/

# locate all hand-classified labels (hand_labels_noise.txt)
OBIWANdata=$(find ${taskDir} -type d  -name "melodic_run.ica")

echo "Data used to train the classifier: ${OBIWANdata[*]}"

###################
# train classifier: generates a <classifierName>.Rdata file that is the classifier (all output is generated in user home directory)

echo "Started training classifier at $(date +"%T")"

# train classifier (-l flag runs a full LOO test)
/usr/local/fix1.066/fix -t ${classifierName} -l ${OBIWANdata[*]}

echo "Finished training classifier at $(date +"%T")"
