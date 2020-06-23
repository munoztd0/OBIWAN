#!/bin/bash

# session level script
sessionScript=/home/OBIWAN/CODE/PREPROC/04-FUGUE_unwarp/fmUnwarp.sh

# loop over subjects
group='control1'
#group='obese2'
#for subjID in	00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	#25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 00 #01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	
  do
  subjectID=${group}${subjID}

	# loop over sessions
	for sessionID in second
	do

		# loop over tasks
		for taskID in pav #PIT hedonicreactivity
		do

			# spawn session jobs to the cluster after the subject level work is complete
			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=0:30:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N unwarp_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${sessionScript}

		done

	done

done
