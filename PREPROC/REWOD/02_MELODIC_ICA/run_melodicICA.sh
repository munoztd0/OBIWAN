#!/bin/bash
home=$(eval echo ~$user)
# session level script
melodicScript=${home}/REWOD/CODE/PREPROC/02_MELODIC_ICA/melodicICA.sh

# Loop over
for subjectID in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 19 21 22 23 24 25 26
do
	# Loop over runs
for taskID in hedonic PIT
do

	#for session in second
		#do
			# EXTRA LONG #spawn session jobs to the cluster after the subject level work is complete
      qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=40:00:00,pmem=10GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ICA_${subjectID}_${taskID} -F "${subjectID} ${taskID} " ${melodicScript}
	done
done
#done
