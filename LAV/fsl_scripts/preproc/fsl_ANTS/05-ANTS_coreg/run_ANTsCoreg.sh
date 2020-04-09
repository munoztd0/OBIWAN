#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/05-ANTS_coreg/

# script to run
anatScript=${codeDir}ANTsCoregAnatomical.sh
funcScript=${codeDir}ANTsCoregRefAndFunc.sh

# Loop over subjects

for subj in control115
#for subj in control100 control102 control105 control106 control107 control108 control109 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control127 control128 control129 control130 control131 control132 control133
#obese200 obese201 obese202 obese203 obese204 obese205 obese206 obese207 obese208 obese209 obese210 obese211 obese212 obese213 obese214 obese215 obese216 obese219 obese220 obese221 obese224 obese225 obese226 obese227

do
	# co-register the anatomicals for comparison
#	 qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=1GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N warpAnatomical_Sub_${subj} -F "${subj}" ${anatScript}


	for sessionID in second
	do

		for taskID in PIT hedonicreactivity
		do

		qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=5GB -M lavinia.wuensch@unige.ch -m e -l nodes=1 -q queue1 -N warpFuncT2_Sub_${subj}_ses_${sessionID}_task-${taskID} -F "${subj} ${sessionID} ${taskID}" ${funcScript}

		done
	done
done
