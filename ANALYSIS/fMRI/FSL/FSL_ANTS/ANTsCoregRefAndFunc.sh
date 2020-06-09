
# set this to the directory containing antsRegistration
ANTSPATH=/usr/local/ANTs/build/bin/

# ITK thread count
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

# Check args
if [ $# -lt 1 ]; then
echo "USAGE: $0 <sbj>"
  exit
fi

sbj=$1
ses=$2
echo Sbject: $sbj
echo Session: $ses


# path to afine transform tool
c3d_affine_tool=/usr/local/c3d/c3d-1.0.0-Linux-x86_64/bin/c3d_affine_tool
# path to the warp tool
warpTool=/usr/local/ANTs/build/bin/WarpImageMultiTransform
# path to the subject's anatomicals
subAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${sbj}/
# Directory with run-specific files
runDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${sbj}/RUN_${ses}/
# directory with ICA cleaned data
icaDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${sbj}/RUN_${ses}.ica/
# path to standard space images
standardAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/


#############
# Define target space (fixed) T1/T2 & masks file names
fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz
fixed_T2=${standardAnatDir}CIT168_T2w_MNI
fixed_T2lowres=${standardAnatDir}CIT168_T2w_MNI_lowres
fixed_mask=${standardAnatDir}`basename ${fixed_T1} .nii.gz`_mask.nii.gz
# Define subject images (moving) T1/T2 & masks file names
moving_T1=${subAnatDir}T1_reoriented_brain
moving_T2=${subAnatDir}T2_reoriented_brain_aligned_T1
# moving_mask=${subAnatDir}`basename ${moving_T1} .nii.gz`_mask.nii.gz
# Prefix for output transform files
# outPrefix=${moving_T1%%.nii.gz}
outPrefix=${moving_T1}

echo "out prefix: ${outPrefix}"


###############
# co-register the functional scan
rawFuncImage=${icaDir}filtered_func_data_clean
funcImage=${icaDir}filtered_func_data_clean_unwarped

echo "Extracting single volume and mean volume and do bias correction $(date +"%T")"
# extract first volume for QA
fslroi ${funcImage} ${icaDir}func_sample 0 1
# we need the mean scan to realign functional within session
fslmaths ${funcImage} -Tmean ${icaDir}mean_func_clean
# perform bias correction on the mean functional
/usr/local/ANTs/build/bin/N4BiasFieldCorrection -i ${icaDir}mean_func_clean.nii.gz -o ${icaDir}func_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]
# run bet another time to improve brain extraction of the mean image used to create the realignement matrix (I'm not sure this is worth it)
bet ${icaDir}func_mean_bias.nii.gz ${icaDir}func_mean_bias.nii.gz -f 0.25 -R

# bring the functional into alignment with the T2, and convert to RAS
echo "Running Flirt Sbj func to T2 $(date +"%T")"
# get correction matrix from flirt
flirt -in ${icaDir}func_mean_bias -ref ${moving_T2} -dof 6 -cost mutualinfo -out ${icaDir}tmp_Func_to_T2 -omat ${icaDir}tmp_Func_to_T2.mat
# second run to flirt to affine alignemnt
flirt -in ${icaDir}func_mean_bias -ref ${moving_T2} -dof 12 -cost mutualinfo -init ${icaDir}tmp_Func_to_T2.mat -nosearch -out ${icaDir}tmp_Func_to_T2_improved -omat ${icaDir}tmp_Func_to_T2.mat

# convert to ras for ANTs
$c3d_affine_tool -src ${icaDir}func_mean_bias -ref ${moving_T2} ${icaDir}tmp_Func_to_T2.mat -fsl2ras -oitk ${icaDir}itk_transform_Func_To_T2.txt

# apply warp to the sample to check quality
echo "Applying warp to functional sample scan"

${warpTool} 3 ${icaDir}func_sample.nii.gz ${icaDir}func_sample_ANTsFuncT2.nii.gz \
        -R ${fixed_T2lowres}.nii.gz \
        ${outPrefix}_xfm1Warp.nii.gz ${outPrefix}_xfm0GenericAffine.mat \
        ${icaDir}itk_transform_Func_To_T2.txt
echo "done sample ANTs at $(date +"%T")"# apply warp to the sample to check quality


# for multi-volume transform
# use this if you want to include go from functional -> anatomical as the warp
echo "Apply series of transformations all the way from func to lowres atlas (in MNI space: test with 10 images only)"

# FOR TESTING (use only the first 10 images)
# fslroi ${icaDir}filtered_func_data_clean_unwarped.nii.gz ${icaDir}func_firstTenTest 0 10

# /usr/local/ANTs/build/bin/WarpTimeSeriesImageMultiTransform 4 ${icaDir}func_firstTenTest.nii.gz ${icaDir}filtered_func_data_clean_unwarped_Coreg.nii.gz \
#	   -R ${fixed_T2lowres}.nii.gz \
#     ${outPrefix}_xfm1Warp.nii.gz ${outPrefix}_xfm0GenericAffine.mat \
#	   ${icaDir}itk_transform_Func_To_T2.txt

# REAL
/usr/local/ANTs/build/bin/WarpTimeSeriesImageMultiTransform 4 ${icaDir}filtered_func_data_clean_unwarped.nii.gz ${icaDir}filtered_func_data_clean_unwarped_Coreg.nii.gz \
	-R ${fixed_T2lowres}.nii.gz \
  ${outPrefix}_xfm1Warp.nii.gz ${outPrefix}_xfm0GenericAffine.mat \
	${icaDir}itk_transform_Func_To_T2.txt

echo "done ants (in MNI space) at $(date +"%T")"
# resample the original to allow comparison
flirt -in ${icaDir}func_sample_bias -ref ${fixed_T2lowres}.nii.gz -dof 7 -out ${icaDir}func_sample_bias_alignT2
