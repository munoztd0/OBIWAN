#!/bin/bash

home=$(eval echo ~$user)

source /opt/anaconda3/etc/profile.d/conda.sh 
conda activate NIpy3

#subjID=$1
#subjID=00
group=$1
#group='control1'


cd ${home}/OBIWAN/DERIVATIVES/MRIQC/after_216_230/

for subjID in	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	#31	32	33	34	35	36	37	38	39	40	41	44	45	46	47	48	49	50	51	52	53	54	56	58	59	62	63	64	65	66	67	68	69	70 #00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 #
#for subjID in  00 01    02	03	05	06	07	08	09	10	12	13	14	15	16	18	19	20	21	22	23	24 	25	26	27	28	29	30	31	32	33
    do
    mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/ ${home}/OBIWAN/DERIVATIVES/MRIQC/after_216_230/ participant --participant-label ${group}${subjID} -m bold
    #mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/ ${home}/OBIWAN/DERIVATIVES/MRIQC2 group -m bold
    echo 'done MRIQC' ${group}${subjID}
    #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC group # --participant-label ${group}${subjectID}

done

#home=$(eval echo ~$user)
#group='control1'
#subjectID='00'
#mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID}  -m T1w T2w