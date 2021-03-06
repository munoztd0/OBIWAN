#!/bin/bash

# session level script
sessionScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/melodicICA.sh
## sessionScript=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/melodicICA.sh

# Loop over
#04 05 07 08 09 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29
for subj in obese200
do
	# Loop over runs, prep fieldmaps and reorient
for run in pavlovianlearning PIT hedonicreactivity
do

	for session in third
		do
			# spawn session jobs to the cluster after the subject level work is complete
      qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=5GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N ICA_${subj}_${run}_${session} -F "${subj} ${run} ${session}" ${sessionScript}
			## qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=10:00:00,pmem=5GB -M evapool@caltech.edu -m e -q batch -N ICA_${subj}_${session} -F "${subj} ${session}" ${sessionScript}
	done
done
done
