#!/bin/bash

codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/06-smoothing_unzip/

smoothScript=${codeDir}smoothFunctional.sh
anatomicalScript=${codeDir}anatomicalClean.sh

# loop over subjects
for subjectID in control100
do

	# copy anatomicals to output directory
	# qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N copyAnat_${subjectID} -F "${subjectID}" ${anatomicalScript}

	# loop over sessions
	for sessionID in second
	do

		# loop over tasks
		for taskID in pavlovianlearning PIT hedonicreactivity
		do
				# spawn session jobs to the cluster after the subject level work is complete
				qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N smoothing_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${smoothScript}

		done

	done

done
