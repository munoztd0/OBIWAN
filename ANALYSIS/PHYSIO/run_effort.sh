#!/bin/bash
home=$(eval echo ~$user);

task="PIT"
#GLM="GLM_07"
codeDir="${home}/REWOD/CODE/ANALYSIS/PHYSIO"
matlab_script="effort_regressor"
matlabSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/matlab_oneSubj.sh"
#PIT

# Loop over subjects

for subj in 01 02 03 04 05 06 07 09 11 13 15 17 18 20 21 22 23 24 25 26 
do
	# prep for each session's data
		qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=0:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N reg_s${subj}_${task} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

done
