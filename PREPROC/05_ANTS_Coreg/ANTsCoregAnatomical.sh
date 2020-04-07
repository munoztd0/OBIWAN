#!/bin/bash

# AUTHOR : Wolfgang Pauli
# LAST MODIFIED BY : DAVID MUNOZ TORD on APRIL 2019

home=$(eval echo ~$user)
ANTSPATH=${home}/REWOD/CODE/PREPROC/05_ANTS_Coreg/

# set this to the directory containing antsRegistration
#ANTSPATH=/usr/local/ANTs/build/bin/


# ITK thread count #look at Insight Toolkit algorythm for more info
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

# Check args
if [ $# -lt 1 ]; then
echo "USAGE: $0 <subjID>"
  exit
fi

subjID=$1
echo subj: $subjID

# path to afine transform tool
#c3d_affine_tool=/usr/local/c3d-1.1.0-Linux-gcc64/bin/c3d_affine_tool

# path to the warp tool
#warpTool=/usr/local/ants/bin/WarpImageMultiTransform

# paths to the T1 structurals,
subAnatDir=${home}/REWOD/CODE/PREPROC/sub-${subjID}/ses-second/anat/

# paths to the standard anatomical images
standardAnatDir=${home}/REWOD/CODE/EXTERNALDATA/CANONICALS/

fixedT1=CIT168_T1w_MNI

# align the T1 anatomicals and downsample to functional resolution
echo "Running Flirt to downsample T1  $(date +"%T")"

flirt -ref ${standardAnatDir}${fixedT1} -in ${standardAnatDir}${fixedT1} -out ${standardAnatDir}${fixedT1}_lowres -applyisoxfm 1.8 -omat ${standardAnatDir}${fixedT1}_lowres.mat
echo "Done Flirt to downsample T1  $(date +"%T")"


#############
# Define target space (fixed) T1 & lowres T1 mask & normal masks file names
fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz
fixed_T1lowres=${standardAnatDir}CIT168_T1w_MNI_lowres.nii.gz
fixed_T1=${standardAnatDir}CIT168_T1w_MNI_mask.nii.gz

# Define subject images (moving) T1/T2 & masks file names
moving_T1=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain.nii.gz
moving_mask=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain_mask.nii.gz

# Prefix for output transform files
Prefix=${moving_T1%%.nii.gz}

#############
echo "anat dir: ${subAnatDir}"
echo "fixed T1: ${fixed_T1}"
echo "fixed mask: ${fixed_mask}"
echo "moving T1: ${moving_T1}"
echo "moving mask: ${moving_mask}"
echo "prefix: ${Prefix}"


# apply warp to the T1 anatomical (also check coreg quality) -R reference_image - use warp transform files previously computed
echo "Apply ANTs wrap to T1 at $(date +"%T")"

${ANTSPATH}WarpImageMultiTransform 3 ${moving_T1} ${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain_ANTsCoreg.nii.gz \
        -R ${fixed_T1lowres} \
        ${Prefix}_xfm1Warp.nii.gz ${Prefix}_xfm0GenericAffine.mat

echo "Done ANTs warp to T1 at $(date +"%T")"


# resample the original so it can be compared (just ot check everything is alright)
echo "resample the original so it can be compared $(date +"%T")"

flirt -in ${moving_T1} -ref ${fixed_T1lowres} -dof 6 -out ${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain_standardAlign.nii.gz
echo "done resampling original $(date +"%T")"
