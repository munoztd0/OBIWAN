#!/bin/bash
home=$(eval echo ~$user)


#Script=${home}/REWOD/CODE/BIDS/mriQC.sh
Script=${home}/REWOD/CODE/BIDS/copy2.sh

# Loop over subjects
 for subjectID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26 #
    do
    #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N CP_sub-${subjectID} -F "${subjectID}"  ${Script}
    qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=84:00:00,pmem=16GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N MRIQC ${Script}

done
