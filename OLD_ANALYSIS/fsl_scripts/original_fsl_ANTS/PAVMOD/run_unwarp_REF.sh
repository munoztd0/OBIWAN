#!/bin/bash

codeDir=/home/REWOD/ANALYSIS/fsl_scripts/fsl_ANTS/
##codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
#anatomicalScript=${codeDir}prepAnatomical.sh
UnwarpScript=${codeDir}fmUnwarp_REF.sh

# Loop over subjects

# for subj in control105
 for subjectID in 01 # 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26

do
	# work on each subject's anatomical scans
	#qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=6GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N prepFEAT_Subject_sub-${subj} -F "${subj}" ${anatomicalScript}
##	qsub -o ~/ClusterOutput -j oe -l walltime=1:00:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj} -F "${subj}" ${anatomicalScript}

  # prep for each session's data
  #for taskID in hedonic PIT
	#for taskID in hedonic PIT
  #do
    qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=0:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N Unwarpfmap-${subjectID}-${taskID}  -F "${subjectID} ${taskID}" ${UnwarpScript}
#		qsub -o ~/ClusterOutput -j oe -l walltime=0:10:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj}_${runID} -F "${subj} ${runID}" ${functionalScript}

  #done
done
