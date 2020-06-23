#!/bin/bash

#codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/01-prepForICA/

codeDir=/home/OBIWAN/CODE/LAV/fsl_scripts/preproc/fsl_ANTS/01-prepForICA/

anatomicalScript=${codeDir}prepAnatomical.sh
functionalScript=${codeDir}prepFunctional.sh
fmapScript=${codeDir}prepFmap.sh

# loop over subjects

group='control1'
#group='obese2'
#for subjID in	00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 00 #01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33 #00 01	02
  subjectID=echo ${group}${subjID}
	# work on anatomicals (about 7 minutes per scan)
 	#qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_anat_sub-${subjectID} -F "${subjectID}" ${anatomicalScript}

  # loop over sessions
  for sessionID in second
  do

	   # loop over tasks
     for taskID in pav #PIT hedonicreactivity
	   do

       # work on functionals
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_func_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${functionalScript}

       # work on fieldmaps
       qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=2:00:00,pmem=6GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N prepForICA_fmap_sub-${subjectID}_ses-${sessionID}_task-${taskID} -F "${subjectID} ${sessionID} ${taskID}" ${fmapScript}

     done

   done

done
