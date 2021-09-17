#!/bin/bash 

cd /home/OBIWAN/DERIVATIVES/GLM/AFNI/HED



3dLMEr -prefix LME \
-jobs 20       \
-model  'condition*perceived_liking*session*intervention+(condition*perceived_liking*session|Subj)+(1|trialxcondition)'          \
-mask mask.nii \
-qVars  'perceived_liking,trialxcondition'                            \
-qVarCenters '0,0'                       \
-gltCode Rew_Neu  'condition : 1*Reward -1*Neutral'            \
-gltCode inter   'condition : 1*Reward session : 1*Post -1*Pre intervention : 1*Treatment -1*Placebo perceived_liking :'   \
-dataTable @HED_LMER.txt\


3dLMEr -prefix LME \
-jobs 20       \
-model  'condition*perceived_liking+(condition*perceived_liking|Subj)+(1|trialxcondition)'          \
-mask mask.nii \
-qVars  'perceived_liking,trialxcondition'                            \
-qVarCenters '0,0'                       \
-gltCode Rew_Neu  'condition : 1*Reward -1*Neutral'                \
-gltCode Rew_NeuXlIk   'condition : 1*Reward -1*Neutral perceived_liking :'                       \
-gltCode RewXlIk   'condition : 1*Reward perceived_liking :'                       \
-dataTable @HED_LMER.txt\




-qVarCenters '0'                       \
#chnage trialxcoinsition

-gltCode pos      'condition : 1*Reward'                       \
-gltCode pos-neg  'condition : 1*Reward -1*Neutral'                \
-gltCode Lik      'condition : 1*Reward perceived_liking :'                       \
#run 3dlme in afni
3dLME  -prefix lme_4 -jobs 20 \
-model "condition*time*intervention*bmiZ+gender+ageZ" \
-mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii \

-gltCode CS-eff1  'CS : 0.5*pos +0.5*neg -1*neu'     \
-glfCode CS-eff2  'CS : 1*pos -1*neg & 1*pos -1*neu' \

#AFNItoNIFTI -prefix test lme+tlrc[5]
for i in 0 1 2 4 6 8
do
#/usr/local/abin/3dAFNItoNIFTI -prefix lme_con${i} LME+tlrc[${i}]
fslmaths lme_con${i} -ztop -add -1 -mul -1 lme_con${i}
done

