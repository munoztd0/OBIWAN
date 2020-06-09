#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/

# script to run
funcScript=${codeDir}ANTS_CoRegFeat.sh
anatScript=${codeDir}ANTsCoregAnatomical.sh

# Loop over subjects
# e.g: for subj in 001 002
for subj in 05
do
	# co-register the anatomicals for comparison
 # qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=0:05:00,pmem=1GB -M evapool@caltech.edu -m e -q batch -N warpAnatomical_Sub_${subj} -F "${subj}" ${anatScript}

	for runID in 01 02 03
	do
		qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=00:10:00,pmem=5GB -M evapool@caltech.edu -m e -q batch -N feat_ANTS_${subj}_${runID} -F "${subj} ${runID}" ${funcScript}
	done
done
