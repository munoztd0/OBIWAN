#!/bin/bash

# session level script
sessionScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/04-FUGUE_unwarp/fmUnwarp.sh

# loop over subjects
for subjectID in control100
do

	# loop over sessions
	for sessionID in second
	do

		# loop over tasks
		for taskID in pavlovianlearning PIT hedonicreactivity
		do

			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=0:30:00,pmem=4GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N unwarp_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${sessionScript}

		done

	done

done
