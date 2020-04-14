#!/bin/bash

home=$(eval echo ~$user)


subjID=$1
group=$2


cd ${home}/OBIWAN/DERIVATIVES/MRIQC/


#mriqc ${home}/REWOD/ ${home}/REWOD/QualityCheck participant #--participant-label 01

for subjectID in 09	10	11	12	13	14	15 16
    do
    mriqc ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/ ${home}/OBIWAN/DERIVATIVES/MRIQC participant --participant-label ${group}${subjectID}
done