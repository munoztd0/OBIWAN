#!/bin/bash
home=$(eval echo ~$user)

SmoothScript=${home}/REWOD/CODE/PREPROC/06_Smoothing/smoothFunc.sh


# Loop over subjects
for subjID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
do
	# Loop over task
	for taskID in PIT hedonic
		do
       qsub -o ${home}/REWOD/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N smoothing_${subjID}_${taskID} -F "${subjID} ${taskID}" ${SmoothScript}
	done

done
