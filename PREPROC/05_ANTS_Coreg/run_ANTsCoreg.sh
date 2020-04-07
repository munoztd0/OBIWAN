#!/bin/bash

# #############
# re-slice target anatomical T1 to match subject (moving) image resolution
# This only needs to be done once for the whole project
home=$(eval echo ~$user)

codeDir=${home}/REWOD/CODE/PREPROC/05_ANTS_Coreg/

# script to run
funcScript=${codeDir}ANTsCoregRefAndFunc.sh
#anatScript=${codeDir}ANTsCoregAnatomical.sh

# Loop over subjects
for subjID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
do
	# co-register the anatomicals for comparison
	 qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ${subjID}_Anat_CoregANTS -F "${subjID}" ${anatScript}

		# for each task
	for taskID in hedonic PIT

	do
		qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ${subjID}_${taskID}_Func_CoregANTS -F "${subjID} ${taskID}" ${funcScript}

	done
done
