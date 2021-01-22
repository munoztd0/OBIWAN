#!/bin/bash

home=$(eval echo ~$user);

task="HED"
GLM="GLM_15"

codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/${task}"
matlab_script="${GLM}_ndLevel"
matlabSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneScript.sh"

qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M david.munoz@etu.unige.ch -m e -q queue1 -N ${task}_${GLM}_2ndlevel- -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
