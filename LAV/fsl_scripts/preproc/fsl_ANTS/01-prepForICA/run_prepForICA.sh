#!/bin/bash

codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/01-prepForICA/

anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh
fmapScript=${codeDir}prepFmap.sh

# loop over subjects
# for subjectID in obese206 obese207 obese209 obese211 obese213 obese215 obese217 obese218 obese220 obese221 obese224 obese225 obese226 obese227 obese228 obese229 obese230 obese231 obese232 obese234 obese235 obese237 obese238 obese239 obese241 obese242 obese244 obese245 obese246 obese248 obese249 obese250 obese251 obese252 obese253 obese254 obese256 obese259 obese262 obese264 obese265 obese266 obese268 obese269 obese270
for subjectID in obese217
do

	# work on anatomicals (about 7 minutes per scan)
 	# qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N prepForICA_anat_sub-${subjectID} -F "${subjectID}" ${anatomicalScript}

  # loop over sessions
  for sessionID in third
  do

	   # loop over tasks
     for taskID in pavlovianlearning
	   do

       # work on functionals
       # qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N prepForICA_func_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${functionalScript}

       # work on fieldmaps
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N prepForICA_fmap_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${fmapScript}

     done

   done

done
