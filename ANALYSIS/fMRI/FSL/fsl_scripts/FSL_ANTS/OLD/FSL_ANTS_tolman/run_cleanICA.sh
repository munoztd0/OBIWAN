#!/bin/bash

# session level script
sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/clean.sh

# 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
for subj in 09 #01 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	# Loop over runs, prep fieldmaps and reorient
	for run in 03 #02 03
		do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=1:30:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N Classify_${subj}_${run} -F "${subj} ${run}" ${sessionScript}
	done
done
