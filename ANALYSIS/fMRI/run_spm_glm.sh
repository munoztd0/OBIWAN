#!/bin/bash
home=$(eval echo ~$user);

task="MVPA"
#GLM="GLM_20"
#ANA="MVPA"
codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/${task}"
#matlab_script="${GLM}_stLevel"
matlab_script="tstats_mvpa_04"
#matlab_script="beta_mvpa_04"
matlabSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneSubj.sh"


# Loop over subjects

for subj in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
do
	# prep for each session's data
		qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=4:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1  -q queue1 -N ${GLM}_s${subj}_${task} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

done
