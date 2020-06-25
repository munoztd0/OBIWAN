3dLMEr -prefix LME \
-jobs 12                         \
-model  'CS*RT+(RT|Subj)'          \
-bounds -2 2                            \
-qVars  'RT'                            \
-qVarCenters 1                          \
-gltCode pos      'CS : 1*pos'                       \
-gltCode neg      'CS : 1*neg'                       \
-gltCode pos-neg  'CS : 1*pos -1*neg'                \
-dataTable                              \
Subj CS  RT  InputFile             \
s1    pos     23   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese201_con-0001.nii \
s1    neg     34   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese201_con-0002.nii \
s2    pos     23   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese202_con-0001.nii \
s2    neg     34   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese202_con-0002.nii \
s3    pos     43   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese203_con-0001.nii \
s3    neg     34   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese203_con-0002.nii \
s4    pos     43   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese204_con-0001.nii \
s4    neg     54   /home/OBIWAN/DERIVATIVES/GLM/SPM/PIT/GLM-01/group/sub-obese204_con-0002.nii \


-gltCode CS-eff1  'CS : 0.5*pos +0.5*neg -1*neu'     \
-glfCode CS-eff2  'CS : 1*pos -1*neg & 1*pos -1*neu' \