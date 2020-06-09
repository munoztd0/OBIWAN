#!/bin/bash
home=$(eval echo ~$user)
# session level script
Script=${home}/OBIWAN/CODE/ANALYSIS/fMRI/fsl_firstlevel.sh

#which group
group='control1'
#group='obese2'

# Loop over control1: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
#obese2: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
 #missing 43 55 57 60
 
#for subjID in 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 06 #01	02	03	04	05	06	07	08	09	10	#11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
    do
    subjID=${group}${subjID}
	# Loop over runs
    for taskID in hedonicreactivity #PIT
        do
        #choose session OR runID=$2
        sessionID='second'
        #chooseGLM OR runID=$2
        glmID='GLM-02'


		# EXTRA LONG #spawn session jobs to the cluster after the subject level work is complete
        qsub -o ${home}/OBIWAN/ClusterOutput -j oe -l walltime=10:00:00,pmem=10GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N GLM_${subjID}_${taskID} -F "${subjID} ${taskID} ${sessionID} ${glmID}" ${Script}
	done
done
#done
