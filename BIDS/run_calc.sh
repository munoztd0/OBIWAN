#!/bin/bash
home=$(eval echo ~$user)



#group='control1'
group='obese2'

#Script=${home}/REWOD/CODE/BIDS/mriQC.sh
Script=${home}/OBIWAN/CODE/BIDS/copy2.sh

#subjID=$1
#group=$2

# Loop over control1: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
#obese2: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
 #missing 43 55 57 60
 for subjectID in 00 01 02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
 #for subjectID in 00 01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
    do
    #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N CP_sub-${subjectID} -F "${subjectID}"  ${Script}
    #pydeface  ${home}/OBIWAN/sub-${group}${subjectID}/ses-first/anat/*_T1.nii.gz
    #pydeface  ${home}/OBIWAN/sub-${group}${subjectID}/ses-first/anat/*_T2.nii.gz
    #echo 'done'
    qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=01:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N copy_${group}${subjectID} -F "${subjectID} ${group}" ${Script}

done
