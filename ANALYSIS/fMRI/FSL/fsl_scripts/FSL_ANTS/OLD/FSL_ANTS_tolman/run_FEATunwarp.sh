#!/bin/bash

# session level script
sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/feat_unwarp.sh

# Loop over
#04 05 07 08 09 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29
for subj in  01 04 05 08 11
do
	# Loop over runs, prep fieldmaps and reorient
	for session in 01 02 03
		do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=2:00:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N FEATunwarp_${subj}_${session} -F "${subj} ${session}" ${sessionScript}
	done

done
