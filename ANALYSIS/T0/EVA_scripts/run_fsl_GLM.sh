#!/bin/bash

# session level script
sessionScript=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/GLM/GLM-MF-19/GLM-MF-19_level1.sh

# Loop over
#  03 04 05 06 07 08 09 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30
for subj in 04  #03 04  05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do

	for session in 01 02 03 #01 02 03
		do
	    # spawn session jobs to the serverq after the subject level work is complete
			qsub -o ~/ClusterOutput -j oe -l walltime=72:00:00,pmem=9GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N GLM-MF-09_${subj}_${session} -F "${subj} ${session}" ${sessionScript}
	done

done
