#!/bin/bash

# session level script
cleanScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/03-FIX/cleanICA.sh

# loop over subjects
for subjectID in control100
do

	# loop over sessions
	for sessionID in second
	do

		# loop over tasks
		for taskID in pavlovianlearning PI hedonicreactivity
		do

			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:30:00,pmem=4GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N classify_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${cleanScript}

		done

	done

done
