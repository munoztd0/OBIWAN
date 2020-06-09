#!/bin/bash

# pull in the subject we should be working on
# subjectID=$1
# sessionID=$2

# I want this to be as slow and discrete as possible so we do it sequentially

for subjectID in 03 04 #05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do

    funcDir=evapool@tolman.caltech.edu:/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/ # copy from tolman
    outDir=/home/eva/PAVMOD/DATA/brain/FLS_ANTS/${subjectID}/ # copy to cisacalc

    echo "Copying unsmoothed Subject ${subjectID} at $(date +"%T")"
    sshpass -p 'Rimerli2' scp -r -l 2000 ${funcDir} ${outDir}
    echo "Finish copying Subject ${subjectID} at $(date +"%T")"
done
