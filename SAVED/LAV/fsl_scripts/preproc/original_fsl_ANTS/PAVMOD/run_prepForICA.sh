#!/bin/bash

##codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/
anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh
fmapScript=${codeDir}prepFmap.sh

# Loop over subjects

for subjectID in control125
do
	# work on each subject's anatomical scans
  #	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_Subject_sub-${subj} -F "${subj}" ${anatomicalScript}
  ##	qsub -o ~/ClusterOutput -j oe -l walltime=1:00:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj} -F "${subj}" ${anatomicalScript}

  for sessionID in second
  do

	   # prep for each session's data
     for taskID in hedonicreactivity
	   do

       # work on functional scans
       # qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_func_Subject_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${functionalScript}
       ## qsub -o ~/ClusterOutput -j oe -l walltime=0:10:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj}_${runID} -F "${subj} ${runID}" ${functionalScript}

       # work on fmaps
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_fmap_Subject_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${fmapScript}

     done
   done
done
