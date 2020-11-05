#!/bin/bash                                                                                                                             

codeDir="/home/OBIWAN/ANALYSIS/spm_scripts/GLM/hedonicreactivity"
matlab_script="GLM_04_getOnsets"
matlabSubmit="/home/OBIWAN/ANALYSIS/spm_scripts/matlab_oneScript.sh"


# get onesets                                                                                                                   
 qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=0:30:00,pmem=4GB -M eva.pool@.unige.ch -m e -l nodes=1  -q queue1 -N ONSETS-3_sub-${subj} -F "${codeDir} ${matlab_script}" ${matlabSubmit}

