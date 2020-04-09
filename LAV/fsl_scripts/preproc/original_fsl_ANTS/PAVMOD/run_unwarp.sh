#!/bin/bash

# session level script
#sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/fmUnwarp.sh
sessionScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/fmUnwarp.sh

for subjectID in control125
do
	# Loop over runs fieldmaps and reorient
	for sessionID in second
	do

		for taskID in pavlovianlearning
		do
		# spawn session jobs to the cluster after the subject level work is complete
#		qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N ApplyFM_${subj}_${run} -F "${subj} ${run}" ${sessionScript}
		qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=0:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N Unwarp_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${sessionScript}

		done

	done

done
