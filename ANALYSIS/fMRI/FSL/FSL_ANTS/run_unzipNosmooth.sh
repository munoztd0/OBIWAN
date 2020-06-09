#!/bin/bash

sessionScript=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/FSL_ANTS/unzipNosmooth.sh

# Loop over subjects
#01 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
for subj in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	# Loop over runs smooth and unzip for SPM use
	for run in 01 02 03
		do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o ~/ClusterOutput -j oe -l walltime=01:30:00,pmem=4GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N smoothing_${subj}_${run} -F "${subj} ${run}" ${sessionScript}
		done
done
