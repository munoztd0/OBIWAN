#!/bin/bash
#group='control1'
group='obese2'
sessionID='second'
#chooseGLM OR runID=$2
glmID='GLM-02'
taskID='hedonicreactivity'
home=$(eval echo ~$user)
for subjID in 01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30 31	32	33	34	35	36	37	38	39	40 41 42	44	45	46	47	48	49	50	51	52	53	54	56	58	59 	61	62	63	64	65	66	67	68	69	70 #
    do
    subjectID=${group}${subjID}
    #hacking FSL first level
    cp -r ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-obese270/output+.feat/reg ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/
    rm ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/reg/*.mat

    cp $FSLDIR/etc/flirtsch/ident.mat ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/reg/example_func2standard.mat
    cp ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/mean_func.nii.gz ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/reg/standard.nii.gz
    cp ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/example_func.nii.gz ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat/reg/example_func.nii.gz
    
    #rm -r ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output+.feat
    #mv ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat

done