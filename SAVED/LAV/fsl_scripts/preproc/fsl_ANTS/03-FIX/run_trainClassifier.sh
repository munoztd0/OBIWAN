#!/bin/bash

# script to run
trainScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/03-FIX/trainClassifier.sh

# submit to cluster (LOO test takes a long time)
qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=500:00:00,pmem=8GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N training_classifier ${trainScript}
