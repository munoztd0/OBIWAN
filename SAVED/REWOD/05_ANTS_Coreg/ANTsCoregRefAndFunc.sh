#!/bin/bash

# AUTHOR : Wolfgang Pauli
# LAST MODIFIED BY : DAVID MUNOZ TORD on NOVEMBER 2019

# set this to the directory containing antsRegistration
#ANTSPATH=/usr/local/ants/bin/


# ITK thread count #look at Insight Toolkit algorythm for more info
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

# Check args
if [ $# -lt 1 ]; then
echo "USAGE: $0 <subjID>"
  exit
fi

subjID=$1
taskID=$2

home=$(eval echo ~$user)

ANTSPATH=${home}/REWOD/CODE/PREPROC/05_ANTS_Coreg/

# path to afine transform tool
#c3d_affine_tool=/usr/local/c3d-1.1.0-Linux-gcc64/bin/c3d_affine_tool

# path to the warp tool
#warpTool=/usr/local/ants/bin/WarpImageMultiTransform

# path to the subject's anatomicals
subAnatDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/anat/

# Directory with run-specific files
runDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/

# directory with ICA cleaned data
icaDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/task-${taskID}.ica/filtered_func_data_clean

# path to standard space images
standardAnatDir=${home}/REWOD/DERIVATIVES/EXTERNALDATA/CANONICALS/


#############
# Define target space (fixed) T1 & masks file names
#fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz
fixed_T1_lowres=${standardAnatDir}CIT168_T1w_MNI_lowres.nii.gz
#fixed_mask=${standardAnatDir}CIT168_T1w_MNI_mask.nii.gz
fixed_mask_lowres=${standardAnatDir}CIT168_T1w_MNI_mask_lowres.nii.gz

# Define subject images (moving) T1/SBref & masks file names
#moving_T1=${subAnatDir}sub-${subjID}_ses-second_runf-01_sbref_reoriented_brain_restore_unwarped
#moving_mask=${subAnatDir}sub-${subjID}_ses-second_run-01_sbref_reoriented_brain_restore_unwarped_mask
moving_T1=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain.nii.gz
moving_mask=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain_mask.nii.gz

# Prefix for output transform files
Prefix=${moving_T1}

echo "prefix: ${Prefix}"

# construct the masks
fslmaths $fixed_T1_lowres -thr .1 -bin $fixed_mask_lowres
fslmaths $moving_T1 -thr .1 -bin $moving_mask

###############
# co-register the functional scan
rawFuncImage=${icaDir}
funcImage=${icaDir}_unwarped

echo "Extracting single volume and mean volume and do bias correction $(date +"%T") an BET"

# extract first volume for QA
fslroi ${funcImage} ${icaDir}_sample 0 1

# we need the mean scan to realign functional within session
fslmaths ${funcImage} -Tmean ${icaDir}_mean

# perform bias correction on the mean functional
${ANTSPATH}N4BiasFieldCorrection -i ${icaDir}_mean.nii.gz -o ${icaDir}_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# run bet another time to improve brain extraction of the mean image used to create the realignement matrix
bet ${icaDir}_mean_bias.nii.gz ${icaDir}_mean_bias.nii.gz -f 0.25 -R
fslmaths ${icaDir}_mean_bias.nii.gz -thr .1 -bin ${icaDir}_mean_bias_mask.nii.gz

# bring the functional into alignment with the T1, and convert to RAS (for ANTS)
echo "Running Flirt subjID func to T1 $(date +"%T")"

# get correction matrix from flirt
flirt -in ${icaDir}_mean_bias -ref ${moving_T1} -dof 6 -cost mutualinfo -out ${icaDir}_tmp_Func_to_T1 -omat ${icaDir}_tmp_Func_to_T1.mat

# second run to flirt to affine alignemnt
flirt -in ${icaDir}_mean_bias -ref ${moving_T1} -dof 12 -cost mutualinfo -init ${icaDir}_tmp_Func_to_T1.mat -nosearch -out ${icaDir}_tmp_Func_to_T1_improved -omat ${icaDir}_tmp_Func_to_T1.mat

# convert to ras for ANTs
${ANTSPATH}c3d_affine_tool -src ${icaDir}_mean_bias -ref ${moving_T1} ${icaDir}_tmp_Func_to_T1.mat -fsl2ras -oitk ${icaDir}_itk_transform_Func_To_T1.txt


# apply warp to the sample to check quality on only one volume
echo "Applying warp to functional sample scan"

${ANTSPATH}WarpImageMultiTransform 3 ${icaDir}_sample.nii.gz ${icaDir}_sample_ANTsFuncT1.nii.gz \
        -R ${fixed_T1_lowres} \
        ${Prefix}_xfm1Warp.nii.gz ${Prefix}_xfm0GenericAffine.mat \
        ${icaDir}_itk_transform_Func_To_T1.txt
echo "done sample ANTs at $(date +"%T")"


# for multi-volume transform
# use this if you want to include go from functional -> anatomical as the warp
echo "Apply series of transformations all the way from func to lowres atlas" ##(in MNI space: test with 10 images only)" (first do that and then do the whole series)

# FOR TESTING !! (use only the first 10 images)
#fslroi ${icaDir}_unwarped.nii.gz ${icaDir}_firstTenTest 0 10

#${warpTool}WarpTimeSeriesImageMultiTransform 4 ${icaDir}_firstTenTest.nii.gz ${icaDir}_unwarped_Coreg_test.nii.gz \
	   #-R ${fixed_T1_lowres} \
     #${Prefix}_xfm1Warp.nii.gz ${Prefix}_xfm0GenericAffine.mat \
	   #${icaDir}_itk_transform_Func_To_T1.txt

# REAL # interpo = kNN
# apply warp to the time image series -R reference template - use warp transform files previously computed
${ANTSPATH}WarpTimeSeriesImageMultiTransform 4 ${icaDir}_unwarped.nii.gz ${icaDir}_unwarped_Coreg.nii.gz \
	-R ${fixed_T1_lowres} \
  ${Prefix}_xfm1Warp.nii.gz ${Prefix}_xfm0GenericAffine.mat \
	${icaDir}_itk_transform_Func_To_T1.txt


echo "done ants (in MNI space) at $(date +"%T")"
# resample the original to allow comparison
ANTSPATH=${home}/REWOD/CODE/PREPROC/04_FUGUE_Unwarping/
${ANTSPATH}N4BiasFieldCorrection -i ${icaDir}_sample.nii.gz -o ${icaDir}_sample_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]
flirt -in ${icaDir}_sample_bias -ref ${fixed_T1_lowres} -dof 7 -out ${icaDir}_sample_bias_alignT1
