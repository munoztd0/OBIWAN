#!/bin/bash

codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh

# Loop over subjects

for subj in 26
do
	# work on each subject's anatomical scans
#	qsub -o ~/ClusterOutput -j oe -l walltime=1:00:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj} -F "${subj}" ${anatomicalScript}

	# prep for each session's data
	for runID in 01  
	do
		qsub -o ~/ClusterOutput -j oe -l walltime=0:10:00 -M evapool@caltech.edu -m e -l nodes=1 -q batch -N prepFEAT_Subject_${subj}_${runID} -F "${subj} ${runID}" ${functionalScript}

	done
done
