#!/bin/bash 

cd /home/OBIWAN/DERIVATIVES/GLM/AFNI/HED
  
  
#run 3dlme in afni
3dLME  -prefix lme_full -jobs 20 \
-model "condition*time*intervention*bmiZ+gender+ageZ" \
-mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii \
-resid  all_residuals \
-qVars 'bmiZ,ageZ' \
-qVarsCenters '0,0' \
-ranEff '~time*condition|Subj' \
-SS_type 3 \
-num_glt 1 \
-gltLabel 1 'Reward-Neutral' -gltCode 1 'condition : 1*Reward -1*Neutral'  \
-dataTable @HED_LME_withcov.txt\

#AFNItoNIFTI -prefix test lme+tlrc[5]
for i in 1 2 3 4 5 6 7 8 9 10 12 12 13 14 15 16 17 18 19
do
/usr/local/abin/3dAFNItoNIFTI -prefix lme_full_con${i} lme_full+tlrc[${i}]
done

++ Smallest FDR q [0 (Intercept)  F] = 1.62341e-14
++ Smallest FDR q [1 condition  F] = 0.000231921
++ Smallest FDR q [2 time  F] = 0.011967
*+ WARNING: Smallest FDR q [3 intervention  F] = 0.242091 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [4 bmiZ  F] = 0.982333 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [5 gender  F] = 0.974395 ==> few true single voxel detections
++ Smallest FDR q [6 ageZ  F] = 0.00465841
*+ WARNING: Smallest FDR q [7 condition:time  F] = 0.239361 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [8 condition:intervention  F] = 0.986481 ==> few true single voxel detections
++ Smallest FDR q [9 time:intervention  F] = 0.000313954
*+ WARNING: Smallest FDR q [10 condition:bmiZ  F] = 0.987223 ==> few true single voxel detections
++ Smallest FDR q [11 time:bmiZ  F] = 0.0176915
*+ WARNING: Smallest FDR q [12 intervention:bmiZ  F] = 0.57236 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [13 condition:time:intervention  F] = 0.808861 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [14 condition:time:bmiZ  F] = 0.987954 ==> few true single voxel detections
*+ WARNING: Smallest FDR q [15 condition:intervention:bmiZ  F] = 0.976662 ==> few true single voxel detections
++ Smallest FDR q [16 time:intervention:bmiZ  F] = 0.000107513
*+ WARNING: Smallest FDR q [17 condition:time:intervention:bmiZ  F] = 0.987439 ==> few true single voxel detections
++ Smallest FDR q [19 Reward-Neutral Z] = 2.7391e-05

#get ddf
3dinfo -verbose lme_full+tlrc[16]