#!/bin/bash

# session level script
cleanScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/03-FIX/cleanICA.sh

# loop over subjects
for subjectID in obese269 obese270
# for subjectID in obese203 obese204 obese205 obese206 obese207 obese209 obese211 obese213 obese215 obese217 obese218 obese220 obese221 obese224 obese225 obese226 obese227 obese228 obese230 obese231 obese232 obese234 obese235 obese237 obese238 obese239 obese241 obese242 obese244 obese246 obese252 obese259 obese262
do

	# loop over sessions
	for sessionID in third
	do

		# loop over tasks
		for taskID in pavlovianlearning PIT hedonicreactivity
		do

			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:30:00,pmem=4GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N classify_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${cleanScript}

		done

	done

done
