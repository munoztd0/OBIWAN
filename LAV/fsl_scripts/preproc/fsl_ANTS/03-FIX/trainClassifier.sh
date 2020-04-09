#!/bin/bash

# name of classifier
classifierName=FIX_obiwan_02

# locate all hand-classified labels
#obiwandata=$(find /home/shared/fix/data/OBIWAN/ -type d  -name "melodic_run*.ica")
obiwandata=$(find /home/shared/fix/data/OBIWAN/ -type d  -name "melodic_run.ica")

echo "Data used to train the classifier: ${obiwandata}"

###################
# train the classifier: will generate an Rdata file that is the classifier

echo "Started training classifier at $(date +"%T")"

# train classifier
/usr/local/fix1.066/fix -t ${classifierName} -l ${obiwandata}

echo "Finished training classifier at $(date +"%T")"
