#!/bin/bash

codeDir="/home/OBIWAN/ANALYSIS/spm_scripts/GLM/hedonicreactivity"
matlab_script="GLM_08_ndLevel"
matlabSubmit="/home/OBIWAN/ANALYSIS/spm_scripts/matlab_oneScript.sh"

qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M evapool@unige.ch -m e -q queue1 -N GLM-02-_ttests-${subj} -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
#qsub -o ~/ClusterOutput -j oe -l walltime=2:00:00,pmem=4GB -M eva.pool@unige.ch -m e -q queue1 -N GLM-03i_sub-${subj} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}
