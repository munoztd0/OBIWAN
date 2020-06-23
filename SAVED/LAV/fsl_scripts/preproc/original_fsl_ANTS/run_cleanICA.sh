#!/bin/bash

# session level script
## sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/clean.sh
sessionScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/clean.sh

# for subj in control100 control102 control105 control106 control107 control108 control109 control110 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control123 control124 control125 control126 control127 control128 control129 control130 control131 control132 control133
for subj in obese210
#for subj in obese200 obese201 obese202 obese203 obese204 obese205 obese206 obese207 obese208 obese209 obese210 obese211 obese213 obese214 obese215 obese216 obese219 obese220 obese221 obese224 obese225 obese226 obese227

do
	# Loop over runs, prep fieldmaps and reorient
	for run in PIT
		do

			for session in second
			do
			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N Classify_${subj}_${run}_${session} -F "${subj} ${run} ${session}" ${sessionScript}

		done
	done
done
