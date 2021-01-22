cd /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/
#-mask /path/to/mask/mask.nii \
3dLME  -prefix lme4.nii -jobs 20 \
-model "CS*Time" \
-ranEff '~1' \
-SS_type 3 \
-num_glt 1 \
-gltLabel 1 'pos-neg' -gltCode 1 'CS : 1*pos -1*neg'  \
-dataTable \
Subj CS Time InputFile  \
201pos  pre GLM-01_0/group/sub-obese201_con-0003.nii \
201 neg pre GLM-01_0/group/sub-obese201_con-0005.nii \
201 pos post GLM-01_1/group/sub-obese201_con-0003.nii \
201 neg post GLM-01_1/group/sub-obese201_con-0005.nii \
202 pos pre GLM-01_0/group/sub-obese202_con-0003.nii \
202 neg pre GLM-01_0/group/sub-obese202_con-0005.nii \
202 pos post GLM-01_1/group/sub-obese202_con-0003.nii \
202 neg post GLM-01_1/group/sub-obese202_con-0005.nii \
203 pos pre GLM-01_0/group/sub-obese203_con-0003.nii \
203 neg pre GLM-01_0/group/sub-obese203_con-0005.nii \
203 pos post GLM-01_1/group/sub-obese203_con-0003.nii \
203 neg post GLM-01_1/group/sub-obese203_con-0005.nii \
204 pos pre GLM-01_0/group/sub-obese204_con-0003.nii \
204 neg pre GLM-01_0/group/sub-obese204_con-0005.nii \
204 pos post GLM-01_1/group/sub-obese204_con-0003.nii \
204 neg post GLM-01_1/group/sub-obese204_con-0005.nii \
205 pos pre GLM-01_0/group/sub-obese205_con-0003.nii \
205 neg pre GLM-01_0/group/sub-obese205_con-0005.nii \
205 pos post GLM-01_1/group/sub-obese205_con-0003.nii \
205 neg post GLM-01_1/group/sub-obese205_con-0005.nii \
214 pos pre GLM-01_0/group/sub-obese214_con-0003.nii \
214 neg pre GLM-01_0/group/sub-obese214_con-0005.nii \




# 3dLME -prefix /path/to/output/output.nii -jobs 6 \
# -model 'time*group+age+sex+interscan+site' \
# -qVars 'age,interscan' \
# -qVarsCenters '12.79,2.1' \
# -ranEff '~1' \
# -SS_type 3 \
# -mask /path/to/mask/mask.nii \
# -num_glt 1 \
# -gltLabel 1 'grpXtime' -gltCode 1 'group : 1*hc -1*pt time : 1*time1 -1*time2' \
# -dataTable \
# Subj time group age sex site interscan InputFile \
# 13649 time1 ctl 13.59 M 1 2.25 13649_GNG_cope2_time3.nii.gz
# 13649 time2 ctl 13.59 M 1 2.25 13649_GNG_cope2_time4.nii.gz
# 15388 time1 ctl 11.64 F 2 ??? 15388_GNG_cope2_time3.nii.gz
# 15341 time1 ctl 12.87 F 3 2.04 15341_GNG_cope2_time3.nii.gz
# 15341 time2 ctl 12.87 F 3 2.04 15341_GNG_cope2_time4.nii.gz
# ...
# 15350 time1 pt 11.69 F 1 2.06 15350_GNG_cope2_time3.nii.gz
# 15350 time2 pt 11.69 F 1 2.06 15350_GNG_cope2_time4.nii.gz
# 15398 time1 pt 10.42 F 3 2.07 15398_GNG_cope2_time3.nii.gz
# 15398 time2 pt 10.42 F 3 2.07 15398_GNG_cope2_time4.nii.gz
# 15403 time1 pt 12.45 M 2 ??? 15403_GNG_cope2_time3.nii.gz