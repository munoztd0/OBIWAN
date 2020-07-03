#!/bin/bash

#use this to run the bash scripts on the cluster efficiently
home=$(eval echo ~$user)

source /opt/anaconda3/etc/profile.d/conda.sh 
conda activate NIpy3

#which group
group='control1'
#group='obese2'


#which script
#Script=${home}/OBIWAN/CODE/BIDS/mriQC.sh
#Script=${home}/OBIWAN/CODE/BIDS/copy2.sh

cd ${home}/OBIWAN/DERIVATIVES/MRIQC/after_control/

#for subjID in	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	#31	32	33	34	35	36	37	38	39	40	41	44	45	46	47	48	49	50	51	52	53	54	56	58	59	62	63	64	65	66	67	68	69	70 #00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 #
for subjID in  00 #02	03	05	06	07	08	09	10	12	13	14	15	16	18	19	20	21	22	23	24 	25	26	27	28	29	30	31	32	33
    do
    mkdir ${group}${subjID}
    cd ${group}${subjID}
    echo 'doing MRIQC' ${group}${subjID}
    mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/sub-control100/ses-second/func/test/ ${home}/OBIWAN/DERIVATIVES/MRIQC/after_control/${group}${subjID}/ participant --participant-label ${group}${subjID} -m bold #--n_procs 10
    #mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/ ${home}/OBIWAN/DERIVATIVES/MRIQC2 group -m bold
    echo 'done MRIQC' ${group}${subjID}
    #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC group # --participant-label ${group}${subjectID}

done
#for subjID in 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
# for subjID in 00 #01	02	03	04	05	06	07	08	09	10	#11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
#     do
    
#     #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N CP_sub-${subjectID} -F "${subjectID}"  ${Script}
#     qsub -o ${home}/OBIWAN/ClusterOutput -j oe -l walltime=80:00:00,pmem=16GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N obQC_${group}${subjID} -F "${subjID} ${group}" ${Script}
#     #cp ${home}/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-third/func/* ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
# done
