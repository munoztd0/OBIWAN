#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
# fixedT1=CIT168_T1w_MNI
# fixedT2=CIT168_T2w_MNI
# echo "Running Flirt to downsample T1 & T2 $(date +"%T")"
# flirt -ref ${codeDir}${fixedT1} -in ${codeDir}${fixedT1} -out ${codeDir}${fixedT1}_lowres -applyisoxfm 2.5 -omat ${codeDir}${fixedT1}_lowres.mat
# flirt -ref ${codeDir}${fixedT2} -in ${codeDir}${fixedT2} -out ${codeDir}${fixedT2}_lowres -applyisoxfm 2.5 -omat ${codeDir}${fixedT2}_lowres.mat
# echo "Done Flirt to downsample T1 & T2 $(date +"%T")"

# script to run
subScript=${codeDir}ANTsAnatomicalWarp.sh

# Loop over subjects
# e.g: for subj in 001 002
# 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
for subj in 30
do
	qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=7:00:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N ANTsAnatomical_Subject_${subj} -F "${subj}" ${subScript}
done
