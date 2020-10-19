#!/bin/bash

##codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/
anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh
fmapScript=${codeDir}prepFmap.sh

# Loop over subjects

for subjectID in obese223
#for subjectID in obese201 obese202 obese203 obese204 obese205 obese206 obese207 obese208 obese209 obese210 obese211 obese213 obese214 obese215 obese216 obese219 obese220 obese221 obese225 obese226 obese227
#for subjectID in control100 control102 control105 control106 control107 control108 control109 control110 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control126 control127 control128 control129 control130 control131 control132 control133

do
	# work on each subject's anatomical scans
  	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_Subject_sub-${subjectID} -F "${subjectID}" ${anatomicalScript}

  for sessionID in second
  do

	   # prep for each session's data
     for taskID in pavlovianlearning PIT hedonicreactivity
	   do

       # work on functional scans
         qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_func_Subject_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${functionalScript}

       # work on fmaps
#        qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_fmap_Subject_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${fmapScript}

     done
   done
done
