#!/bin/bash

# session level script
melodicScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/02-MELODIC_ICA/melodicICA.sh

# loop over subjects
# for subjectID in obese205 obese206 obese207 obese209 obese211 obese213 obese215 obese217 obese218 obese220 obese221 obese224 obese225 obese226 obese227 obese228 obese229 obese230 obese231 obese232 obese234 obese235 obese237 obese238 obese239 obese241 obese242 obese244 obese246 obese248 obese251 obese252 obese253 obese256 obese259 obese262
for subjectID in obese200
do

	# loop over sessions
	for sessionID in third
	do

		# loop over tasks
		for taskID in PIT
		do

			# spawn session jobs to the cluster after the subject level work is complete
      qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=15:00:00,pmem=5GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N melodicICA_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${melodicScript}

		done

	done

done
