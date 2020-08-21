#!/bin/bash 

cd /home/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/eff/

#run 3dlme in afni
3dLME  -prefix lme_full_withcov -jobs 120 \
 -model "eff*condition*time*intervention+gender+ageC" \
 -mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii \
 -resid  all_residuals \
 -qVars 'eff,ageC' \
 -qVarsCenters '0,0' \
 -ranEff '~condition*time|Subj' \
 -SS_type 3 \
 -num_glt 1 \
 -gltLabel 1 'CSplus-CSminus' -gltCode 1 'condition : 1*1 -1*-1'  \
 -dataTable @PIT_LME_withcov.txt\


cd /home/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/GLM-01/

#run 3dlme in afni
3dLME  -prefix lme_full_nocov -jobs 120 \
 -model "condition*time*intervention" \
 -mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii \
 -resid  all_residuals \
 -ranEff '~condition*time|Subj' \
 -SS_type 3 \
 -num_glt 1 \
 -gltLabel 1 'CSplus-CSminus' -gltCode 1 'condition : 1*1 -1*-1'  \
 -dataTable @PIT_LME_withcov.txt\

# cd /home/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/icc
# #run 3dlme in afni witth icc
# 3dLME  -prefix lme_full_withcov -jobs 120 \
# -model "1" \
# -ranEff 'Subj' \
# -ICC \
# -dataTable @PIT_LME_withcov.txt\

#There are three ways to interpret the ICC value. The first one is probably more popular: ICC measures the proportion of total variance that is attributable to an explanatory variable (typically a categorical variable such as session, scanner, etc.). However I feel the second interpretation is more intuitive: ICC is the expected correlation between any two effect estimates randomly drawn from the same level of the categorical variable. 

#AFNItoNIFTI -prefix test lme+tlrc[5]
for i in 1 2 3 4 5 6 7 8 9 #10 12 12 13 14 15 16 17 18 19
do
/usr/local/abin/3dAFNItoNIFTI -prefix lme_full_withcov_con${i} lme_full_withcov+tlrc[${i}]
done



# ++ Smallest FDR q [0 (Intercept)  F] = 1.62341e-14
# ++ Smallest FDR q [1 condition  F] = 0.000231921
# ++ Smallest FDR q [2 time  F] = 0.011967
# *+ WARNING: Smallest FDR q [3 intervention  F] = 0.242091 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [4 bmiZ  F] = 0.982333 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [5 gender  F] = 0.974395 ==> few true single voxel detections
# ++ Smallest FDR q [6 ageZ  F] = 0.00465841
# *+ WARNING: Smallest FDR q [7 condition:time  F] = 0.239361 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [8 condition:intervention  F] = 0.986481 ==> few true single voxel detections
# ++ Smallest FDR q [9 time:intervention  F] = 0.000313954
# *+ WARNING: Smallest FDR q [10 condition:bmiZ  F] = 0.987223 ==> few true single voxel detections
# ++ Smallest FDR q [11 time:bmiZ  F] = 0.0176915
# *+ WARNING: Smallest FDR q [12 intervention:bmiZ  F] = 0.57236 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [13 condition:time:intervention  F] = 0.808861 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [14 condition:time:bmiZ  F] = 0.987954 ==> few true single voxel detections
# *+ WARNING: Smallest FDR q [15 condition:intervention:bmiZ  F] = 0.976662 ==> few true single voxel detections
# ++ Smallest FDR q [16 time:intervention:bmiZ  F] = 0.000107513
# *+ WARNING: Smallest FDR q [17 condition:time:intervention:bmiZ  F] = 0.987439 ==> few true single voxel detections
# ++ Smallest FDR q [19 Reward-Neutral Z] = 2.7391e-05

#get ddf
3dinfo -verbose lme_full+tlrc

#get acf or just use -fwhm 8
3dFWHMx -acf NULL -mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii /home/OBIWAN/DERIVATIVES/GLM/AFNI/PIT/no_cov/all_residuals+tlrc.BRIK
 #0.36352  6.29502  15.4729
 
#run 3dclust sim to control for mutli comp
3dClustSim -mask /home/OBIWAN/DERIVATIVES/EXTERNALDATA/LABELS/GM/CIT_GM.nii -acf 0.36352  6.29502  15.4729
#The columns correspond to differnt levels of FWE (you probably want the column labeled .05000), while the rows correspond to voxel-level p-values. The values in each table cell are the minimum cluster sizes, in voxels, for ensuring the column-level FWE. Thus, in the above, if you wanted to control the FWE at .05, you could view your results in SPM using a voxel-level threshold of .001 and a cluster extent threshold of 19 (you can’t use 18.8 because these have to be whole numbers).

