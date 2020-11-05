#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/05-ANTS_coreg/

# scripts to run
anatScript=${codeDir}ANTsCoregAnatomical.sh
funcScript=${codeDir}ANTsCoregRefAndFunc.sh

# loop over subjects
for subjectID in control100
do

	# co-register the anatomicals for comparison
	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=1GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N warpAnatomical_sub-${subjectID} -F "${subjectID}" ${anatScript}

	# loop over sessions
	for sessionID in second
	do

		# loop over tasks
		for taskID in pavlovianlearning PIT hedonicreactivity
		do

			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=5GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N warpFuncT2_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${funcScript}

		done

	done

done
