#!/bin/bash

codeDir="/home/OBIWAN/ANALYSIS/spm_scripts/GLM/hedonicreactivity"
matlab_script="GLM_17_stLevel"
matlabSubmit="/home/OBIWAN/ANALYSIS/spm_scripts/matlab_oneSubj.sh"


# Loop over subjects

for subj in control100 control102 control105 control106 control107 control108 control110 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control126 control127 control129 control130 control131 control132 control133
#for subj in control100 control102 control105 control106 control107 control108 control109 control110 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control126 control127 control128 control129 control130 control131 control132 control133
#for subj in control115

do
	# do first level
		qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=4:00:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1  -q queue1 -N GLM-3_sub-${subj} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

done
