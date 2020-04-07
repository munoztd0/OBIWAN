#!/bin/bash

home=$(eval echo ~$user)

ANTSwarp=${home}/REWOD/CODE/PREPROC/05_ANTS_Coreg/ANTsAnatomicalWarp.sh

#super long
# Loop over subjects
for subjID in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26

do
	qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=12:00:00,pmem=4GB -M david.munoz@etu.unige -m e -l nodes=1 -q queue1 -N ${subjID}_ANTs_Warp_Anat -F "${subjID}" {$ANTSwarp}
done
