#!/bin/bash

# session level script
sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/fmUnwarp.sh

for subj in  06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	# Loop over runs fieldmaps and reorient
	for run in 01 02 03
		do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N ApplyFM_${subj}_${run} -F "${subj} ${run}" ${sessionScript}
	done
done
