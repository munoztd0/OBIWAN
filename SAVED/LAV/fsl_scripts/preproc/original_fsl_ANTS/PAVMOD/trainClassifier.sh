#!/bin/bash


classifierName=FIX_obiwan


# obiwan datadir
#obiwandata=$(find /home/shared/fix/data/OBIWAN/ -type d  -name "melodic_run*.ica")
obiwandata=$(find /home/shared/fix/data/OBIWAN/ -type d  -name "melodic_run.ica")
echo "data used to train the classifier: ${obiwandata}"

# train the classifier: will generate a an Rdata file that is the classifier
echo "training classifier started at $(date +"%T")"
/usr/local/fix1.066/fix -t ${classifierName} -l ${obiwandata}
echo "training classifier finished at $(date +"%T")"
