#!/bin/bash

home=$(eval echo ~$user)

source /opt/anaconda3/etc/profile.d/conda.sh 
conda activate NIpy3

#subjID=$1
subjID=00
#group=$2
group='control1'


cd ${home}/OBIWAN/DERIVATIVES/MRIQC3


#mriqc ${home}/REWOD/ ${home}/REWOD/QualityCheck participant #--participant-label 01

#for subjID in 24 #	25	26	27	28	29	30	31	32	33 # 00 01	02	03	04	05	06	07	08	09	10 11	12	13	14	15	16	17	18	19	20	21	22	23	#
    #do
   #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID} --modalities [T1w T2w]
    #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjID}  -m smoothBold
mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/ ${home}/OBIWAN/DERIVATIVES/MRIQC3 participant --participant-label ${group}${subjID} --task 'pav'
    #mriqc ${home}/OBIWAN/DERIVATIVES/PREPROC/ ${home}/OBIWAN/DERIVATIVES/MRIQC2 group -m bold


    #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC group # --participant-label ${group}${subjectID}

#done

#home=$(eval echo ~$user)
#group='control1'
#subjectID='00'
#mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID}  -m T1w T2w