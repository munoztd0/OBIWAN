#!/bin/bash

codeDir=/home/OBIWAN/CODE/PREPROC/06-smoothing_unzip/

smoothScript=${codeDir}smoothFunctional.sh
anatomicalScript=${codeDir}anatomicalClean.sh

# loop over subjects
#group='obese2'
group='control1'
#for subjID in 28 29 30 31 32 33	34	35	36	37	38	39	40	41	44	45	46	47	48	49	50	51	52	53	54	56	58	59	62	63	#64	65	66	67	68	69	70 #00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32
#for subjID in	29	30	31	32	34	35	36	37	38	39	41	42	44	45	46	48	49	50	51	52	53	54	56	59	62	#64	65	66	68	69	70 #00 01 02 03	04	05	06	07	08	09	11	13	15	17	18	20	21	24	25	26	27	28
for subjID in 22 #28	29	30	31	32	33 #00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	
  do
  subjectID=${group}${subjID}

	# copy anatomicals to output directory
	# qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N cpAnat_${subjectID} -F "${subjectID}" ${anatomicalScript}

	# loop over sessions
	for sessionID in second # third #
	do

		# loop over tasks
		for taskID in PIT hedonicreactivity pavlovianlearning #pav 
		do
				# spawn session jobs to the cluster after the subject level work is complete
				qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N smo_${subjectID}_${sessionID}_${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${smoothScript}

		done

	done

done
