#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/05-ANTS_coreg/
# fixedT1=CIT168_T1w_MNI
# fixedT2=CIT168_T2w_MNI
# echo "Running Flirt to downsample T1 & T2 $(date +"%T")"
# flirt -ref ${codeDir}${fixedT1} -in ${codeDir}${fixedT1} -out ${codeDir}${fixedT1}_lowres -applyisoxfm 2.5 -omat ${codeDir}${fixedT1}_lowres.mat
# flirt -ref ${codeDir}${fixedT2} -in ${codeDir}${fixedT2} -out ${codeDir}${fixedT2}_lowres -applyisoxfm 2.5 -omat ${codeDir}${fixedT2}_lowres.mat
# echo "Done Flirt to downsample T1 & T2 $(date +"%T")"

# script to run
subScript=${codeDir}ANTsAnatomicalWarp.sh

# loop over subjects
for subj in control100
do

	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=12:00:00,pmem=4GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N ANTsAnatomical_Subject_${subj} -F "${subj}" ${subScript}

done
