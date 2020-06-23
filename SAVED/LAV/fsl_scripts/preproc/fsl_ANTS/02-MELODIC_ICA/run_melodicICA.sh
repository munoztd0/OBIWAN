#!/bin/bash

# session level script
melodicScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/02-MELODIC_ICA/melodicICA.sh

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
      qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=15:00:00,pmem=5GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N melodicICA_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${melodicScript}

		done

	done

done
