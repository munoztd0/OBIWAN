#!/bin/bash

home=$(eval echo ~$user)

UnwarpScript=${home}/REWOD/CODE/PREPROC/04_FUGUE_unwarping/fmUnwarp.sh


# Loop over subjects
for subjectID in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
do

  # prep for each task
  for taskID in hedonic PIT
  do
    qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=0:60:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N Unwarp-${subjectID}-${taskID}  -F "${subjectID} ${taskID}" ${UnwarpScript}
  done
done
