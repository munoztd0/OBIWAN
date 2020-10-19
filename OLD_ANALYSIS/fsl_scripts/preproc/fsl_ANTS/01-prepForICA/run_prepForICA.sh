#!/bin/bash

codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/01-prepForICA/

anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh
fmapScript=${codeDir}prepFmap.sh

# loop over subjects
for subjectID in control100
do

	# work on anatomicals (about 7 minutes per scan)
 	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_anat_sub-${subjectID} -F "${subjectID}" ${anatomicalScript}

  # loop over sessions
  for sessionID in second
  do

	   # loop over tasks
     for taskID in pavlovianlearning PIT hedonicreactivity
	   do

       # work on functionals
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_func_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${functionalScript}

       # work on fieldmaps
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_fmap_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${fmapScript}

     done

   done

done
