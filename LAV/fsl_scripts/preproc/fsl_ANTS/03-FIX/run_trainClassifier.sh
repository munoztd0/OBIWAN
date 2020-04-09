#!/bin/bash


# script to run
scriptdir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/03-FIX/trainClassifier.sh

#submit to cluster (estimation will need to be adapted: about 2 hours)
qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=5:00:00,pmem=8GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N training_classifier ${scriptdir}
