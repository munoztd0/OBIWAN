#!/bin/bash

home=$(eval echo ~$user);
#name the classfier
classifierName=FIX_REWOD

# REWOD datadir
REWODdata=${home}/REWOD/CODE/PREPROC/03_FIX_denoise/

echo "data used to train the classifier: ${REWODdata}"
# train the classifier: will generate a an Rdata (IN you home folder) file that is the classifier
echo "training classifier started at $(date +"%T")"
${REWODdata}fix -t ${classifierName} -l ${REWODdata}
echo "training classifier finished at $(date +"%T")"
