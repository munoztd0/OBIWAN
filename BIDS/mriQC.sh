#!/bin/bash

home=$(eval echo ~$user)


subjID=$1
group=$2


cd ${home}/OBIWAN/DERIVATIVES/MRIQC/


#mriqc ${home}/REWOD/ ${home}/REWOD/QualityCheck participant #--participant-label 01

for subjectID in 01	02	03	04	05	06	07 #21	#22	23	24	25	26	27	28	29	30	31	32	33 #01	02	03	04	05	06	07	08	09	10 11	12	13	14	15	16	17	18	19	20	#
    do
   # mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID} --modalities [T1w T2w]
    mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID}  -m T1w T2w
    #mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC group # --participant-label ${group}${subjectID}

done

#home=$(eval echo ~$user)
#group='control1'
#subjectID='00'
#mriqc ${home}/OBIWAN/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID}  -m T1w T2w