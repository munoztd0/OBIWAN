#!/bin/bash


# script to run
scriptdir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/trainClassifier.sh

#submit to cluster (estimation will need to be adapted)
qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=6:00:00,pmem=8GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N training_classifier ${scriptdir}
