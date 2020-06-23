#!/bin/bash

prepScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/03-FIX/prepForTraining.sh

# loop over subjects
for subjectID in control100
do

  # loop over sessions
  for sessionID in second
  do

    # loop over tasks
    for taskID in pavlovianlearning PIT hedonicreactivity
    do

      # prepare FIX training data
      qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=0:30:00,pmem=4GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N prepTrain_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${prepScript}

    done

  done

done
