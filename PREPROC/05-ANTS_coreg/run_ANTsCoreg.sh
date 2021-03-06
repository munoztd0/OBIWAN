#!/bin/bash
# #############

codeDir=/home/OBIWAN/CODE/PREPROC/05-ANTS_coreg/

# scripts to run
anatScript=${codeDir}ANTsCoregAnatomical.sh
funcScript=${codeDir}ANTsCoregRefAndFunc.sh

# loop over subjects


group='obese2'
#00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24 25	26 27 28	29	30	31	32	33 34	35	36	37	38	39	40	41	42	44	45	46 47	48	49	50	51	52	53	54	56	58 59	62	63	64	65	66	67	68	69	70
for subjID in 33 40 47 58 63 67 #	 10 14 16 19 22 23 #
#group='control1'
#for subjID in 08 10	12	13	14	15	16	17	18	19	21	22	23	24	25	26	27	28	29	30	31	32
#for subjID in 00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
  do
  subjectID=${group}${subjID}
	# co-register the anatomicals for comparison
	#qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=1GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N reg-${subjectID}_anat -F "${subjectID}" ${anatScript}

	# loop over sessions
	for sessionID in second #third #
	do

		# loop over tasks
		for taskID in pavlovianlearning pav  PIT hedonicreactivity # pavlovianlearning = inst
		do	

			qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=5GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue2 -N reg-${subjectID}-${sessionID}_task-${taskID}_funcToT2 -F "${subjectID} ${sessionID} ${taskID}" ${funcScript}

		done

	done

done
