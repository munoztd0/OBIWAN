#!/bin/bash
# script to run
home=$(eval echo ~$user);

cleanscript=${home}/REWOD/ANALYSIS/fsl_scripts/fsl_ANTS/clean_preproc/03_FIX_denoise/cleanClass.sh

# Loop over subj
for subjectID in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26 #
do
	# Loop over task
  for taskID in PIT hedonic
  do
	#submit to cluster
	qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=00:40:00,pmem=5GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N Classify_${subj}_${taskID} -F "${subjectID} ${taskID} " ${cleanscript}
	done
done
