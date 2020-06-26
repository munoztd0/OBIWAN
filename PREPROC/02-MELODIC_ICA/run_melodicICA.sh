#!/bin/bash

# session level script
melodicScript=/home/OBIWAN/CODE/PREPROC/02-MELODIC_ICA/melodicICA.sh

# loop over subjects 24 per 24
#group='control1'
group='obese2'
for subjID in 28	29	30	31	32	33	34	35	36	37	38	39 40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70 	#00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	#
#for subjID in 21 22 #00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33 
  do
  subjectID=${group}${subjID}

	# loop over sessions
	for sessionID in third #second
	do

		# loop over tasks
		for taskID in pav # PIT hedonicreactivity
		do

		# spawn session jobs to the cluster after the subject level work is complete
      	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=25:00:00,pmem=5GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue2 -N ICA-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${melodicScript}

		done

	done

done
