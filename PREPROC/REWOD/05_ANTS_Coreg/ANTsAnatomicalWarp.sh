#!/bin/bash
#
# Affine registration of different modalities from the same subject (eg T1w) with
# slightly different geometry or head position (motion, etc)
#
# AUTHOR : Wolfgang Pauli
# LAST MODIFIED BY : DAVID MUNOZ TORD on APRIL 2019


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

home=$(eval echo ~$user)


#############
# set this to the directory containing antsRegistration
#ANTSPATH=/usr/local/ants/bin/
ANTSPATH=${home}/REWOD/CODE/PREPROC/05_ANTS_Coreg/

# path to afine transform tool
#c3d_affine_tool=/usr/local/c3d-1.1.0-Linux-gcc64/bin/c3d_affine_tool

# paths to the subject anatomicals
subAnatDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/anat/

# paths to the standard anatomical images  ##WE USED THE CIT168 TEMPLATE##
standardAnatDir=${home}/REWOD/DERIVATIVES/EXTERNALDATA/CANONICALS/



#############
# Define target space (fixed) T1 & masks file names
fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz

fixed_mask=${standardAnatDir}CIT168_T1w_MNI_mask.nii.gz

# Define subject images (moving) T1 & masks file names
moving_T1=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain.nii.gz
moving_mask=${subAnatDir}sub-${subjID}_ses-second_run-01_T1w_reoriented_brain_mask.nii.gz

# Prefix for output transform files
outPrefix=${moving_T1%%.nii.gz}


echo "anat dir: ${subAnatDir}"
echo "fixed T1: ${fixed_T1}"
echo "fixed mask: ${fixed_mask}"
echo "moving mask: ${moving_mask}"
echo "out prefix: ${outPrefix}"



#############
# align T1
# construct the mask
fslmaths $fixed_T1 -thr .1 -bin $fixed_mask

# align subject T1 to common space target
echo "Running initial fixed/target alignment at $(date +"%T")"

flirt -ref $fixed_T1 -in $moving_T1 -out tmp_sub-${subjID} -omat tmp_sub-${subjID}.mat
echo "Done initial fixed/target alignment at $(date +"%T")"

# convert image format so the affine tool can read it
echo "Converting fsl transformation to ras format at $(date +"%T")"

${ANTSPATH}c3d_affine_tool -ref $fixed_T1 -src $moving_T1 tmp_sub-${subjID}.mat -fsl2ras -oitk itk_transformation_sub-${subjID}.txt

# shape the MASK
echo "Applying affine transformation to mask at $(date +"%T")"

${ANTSPATH}WarpImageMultiTransform 3 $fixed_mask $moving_mask -R $moving_T1 -i itk_transformation_sub-${subjID}.txt


echo  "Running ants registration at $(date +"%T")"
# Deformable
${ANTSPATH}antsRegistration \
   --verbose 1 \
   --dimensionality 3 \
   --initial-moving-transform itk_transformation_sub-${subjID}.txt \
   --metric CC[ $fixed_T1, $moving_T1, .8, 4] \
   --transform Syn[0.1,3,0] \
   --convergence [100x100x70x50x20, 1.e-6, 10] \
   --smoothing-sigmas 5x3x2x1x0vox \
   --shrink-factors 10x6x4x2x1 \
   --use-histogram-matching 1 \
   -x [ $fixed_mask, $moving_mask ] \
   --interpolation Linear \
   -o [ ${outPrefix}_xfm, ${outPrefix}_warped.nii.gz ]

# outputs : _xfm0GenericAffine.mat _xfm1Warp.nii.gz _xfm1InverseWarp.nii.gz #!!


 echo  "Finished ants registration at $(date +"%T")"

# cleanup
rm itk_transformation_sub-${subjID}.txt
rm tmp_sub-${subjID}.mat
rm tmp_sub-${subjID}.nii.gz
