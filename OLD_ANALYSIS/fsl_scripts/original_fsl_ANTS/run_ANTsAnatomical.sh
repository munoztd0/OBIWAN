#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
#codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/
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
#for subj in control100 control102 control105 control106 control107 control108 control109 control110 control112 control113 control114 control115 control116 control119 control120 control121 control122 control123 control124 control125 control126 control127 control128 control129 control130 control131 control132 control133 obese200 obese201 obese202 obese203 obese204 obese205 obese206 obese207 obese208 obese209 obese210 obese211 obese212 obese213 obese214 obese215 obese216 obese219 obese220 obese221 obese224 obese225 obese226 obese227

for subj in control102
do

	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=12:00:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N ANTsAnatomical_Subject_${subj} -F "${subj}" ${subScript}

done
