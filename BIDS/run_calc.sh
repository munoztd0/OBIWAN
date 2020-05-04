#!/bin/bash

#use this to run the bash scripts on the cluster efficiently
home=$(eval echo ~$user)


#which group
group='control1'
#group='obese2'


#which script
Script=${home}/OBIWAN/CODE/BIDS/mriQC.sh
#Script=${home}/OBIWAN/CODE/BIDS/copy2.sh



# Loop over control1: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
#obese2: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
 #missing 43 55 57 60
 
#for subjID in 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 00 #01	02	03	04	05	06	07	08	09	10	#11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
    do
    #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N CP_sub-${subjectID} -F "${subjectID}"  ${Script}
    qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=80:00:00,pmem=16GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N obQC_${group}${subjID} -F "${subjID} ${group}" ${Script}
    #cp ${home}/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-third/func/* ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
done
