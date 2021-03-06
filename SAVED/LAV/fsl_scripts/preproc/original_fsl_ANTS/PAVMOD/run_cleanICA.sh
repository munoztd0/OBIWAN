#!/bin/bash

# session level script
## sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/clean.sh
sessionScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/clean.sh

# 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
## for subj in 09 #01 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
## for subj in control106 control108 control109 control110 control112 control113 control114 control115 control116 control118 control119 control118 control120 control121 control122 control123 control124 control125 control126 obese200 obese201 obese202 obese203 obese204 obese205 obese206 obese207 obese208 obese209 obese210 obese211
for subj in control122
do
	# Loop over runs, prep fieldmaps and reorient
	for run in hedonicreactivity
		do

			for session in second
			do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N Classify_${subj}_${run}_${session} -F "${subj} ${run} ${session}" ${sessionScript}
			## qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=1:30:00,pmem=4GB -M evapool@caltech.edu -m e -q batch -N Classify_${subj}_${run} -F "${subj} ${run}" ${sessionScript}
		done
	done
done
