#!/bin/bash
#
# Affine registration of different modalities from the same subject (eg T1 and T2) with
# slightly different geometry or head position (motion, etc)
#
# AUTHOR : Wolfgang Pauli
# PLACE : Caltech
# DATES : 01/08/2015


# ITK thread count
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

# Check args
if [ $# -lt 1 ]; then
echo "USAGE: $0 <sbjID>"
  exit
fi

sbjID=$1
echo sbjID: $sbjID

#############
# set this to the directory containing antsRegistration
#ANTSPATH=/usr/local/ANTs/build/bin/
ANTSPATH=/usr/local/ants/bin/
# path to afine transform tool
#c3d_affine_tool=/usr/local/c3d/c3d-1.0.0-Linux-x86_64/bin/c3d_affine_tool
c3d_affine_tool=/usr/local/c3d-1.1.0-Linux-gcc64/bin/c3d_affine_tool
# paths to the subject anatomicals, and the standard anatomical images
#subAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${sbjID}/
subAnatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${sbjID}/ses-first/anat/
#standardAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/
standardAnatDir=/home/OBIWAN/DATA/CANONICALS/


# #############
# # Define target space (fixed) T1/T2 & masks file names
# fixed_T1=`imglob -extension .nii.gz ${standardAnatDir}CIT168_T1w_MNI.nii.gz`
# fixed_T2=`imglob -extension .nii.gz ${standardAnatDir}CIT168_T2w_MNI.nii.gz`
# fixed_mask=${standardAnatDir}`basename ${fixed_T1} .nii.gz`_mask.nii.gz
# # Define subject images (moving) T1/T2 & masks file names
# moving_T1=`imglob -extension .nii.gz ${subAnatDir}T1_reoriented_brain.nii.gz`
# moving_T2=`imglob -extension .nii.gz ${subAnatDir}T2_reoriented_brain_aligned_T1.nii.gz`
# moving_mask=${subAnatDir}`basename ${moving_T1} .nii.gz`_mask.nii.gz
# # Prefix for output transform files
# outPrefix=${moving_T1%%.nii.gz}




#############
# Define target space (fixed) T1/T2 & masks file names
fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz
fixed_T2=${standardAnatDir}CIT168_T2w_MNI.nii.gz
fixed_mask=${standardAnatDir}`basename ${fixed_T1} .nii.gz`_mask.nii.gz
# Define subject images (moving) T1/T2 & masks file names
#moving_T1=${subAnatDir}T1_reoriented_brain.nii.gz
moving_T1=${subAnatDir}sub-${sbjID}_ses-first_run-01_T1_reoriented_brain.nii.gz
#moving_T2=${subAnatDir}T2_reoriented_brain_aligned_T1.nii.gz
moving_T2=${subAnatDir}sub-${sbjID}_ses-first_run-01_T2_reoriented_brain_aligned_T1.nii.gz
moving_mask=${subAnatDir}`basename ${moving_T1} .nii.gz`_mask.nii.gz

# Prefix for output transform files
outPrefix=${moving_T1%%.nii.gz}

#############
# align T2 to the T1
echo "anat dir: ${subAnatDir}"
echo "fixed T1: ${fixed_T1}"
echo "fixed T2: ${fixed_T2}"
echo "fixed mask: ${fixed_mask}"
echo "moving T1: ${moving_T1}"
echo "moving T2: ${moving_T2}"
echo "moving mask: ${moving_mask}"
echo "out prefix: ${outPrefix}"

echo "started T1/T2 alignment at $(date +"%T")"
#flirt -in ${subAnatDir}T2_reoriented_brain -ref ${moving_T1} -out ${moving_T2}
flirt -in ${subAnatDir}sub-${sbjID}_ses-first_run-01_T2_reoriented_brain -ref ${moving_T1} -out ${moving_T2}
echo "finished T1/T2 alignment at $(date +"%T")"


# construct the mask
fslmaths $fixed_T1 -thr .1 -bin $fixed_mask

# align subject T1 to common space target
echo "Running initial fixed/target alignment at $(date +"%T")"
#flirt -ref $fixed_T1 -in $moving_T1 -out tmp_${sbjID} -omat tmp_${sbjID}.mat
flirt -ref $fixed_T1 -in $moving_T1 -out tmp_sub-${sbjID} -omat tmp_sub-${sbjID}.mat
echo "Done initial fixed/target alignment at $(date +"%T")"

# convert image format so the affine tool can read it
echo "Converting fsl transformation to ras format at $(date +"%T")"
#$c3d_affine_tool -ref $fixed_T1 -src $moving_T1 tmp_${sbjID}.mat -fsl2ras -oitk itk_transformation_${sbjID}.txt
$c3d_affine_tool -ref $fixed_T1 -src $moving_T1 tmp_sub-${sbjID}.mat -fsl2ras -oitk itk_transformation_sub-${sbjID}.txt

# shape the mask
echo "Applying affine transformation to mask at $(date +"%T")"
#${ANTSPATH}WarpImageMultiTransform 3 $fixed_mask $moving_mask -R $moving_T1 -i itk_transformation_${sbjID}.txt
${ANTSPATH}WarpImageMultiTransform 3 $fixed_mask $moving_mask -R $moving_T1 -i itk_transformation_sub-${sbjID}.txt


echo  "Running ants registration at $(date +"%T")"
# Deformable
${ANTSPATH}antsRegistration \
   --verbose 1 \
   --dimensionality 3 \
   --initial-moving-transform itk_transformation_sub-${sbjID}.txt \
   --metric CC[ $fixed_T1, $moving_T1, .8, 4] \
   --metric CC[ $fixed_T2, $moving_T2, .2, 4] \
   --transform Syn[0.1,3,0] \
   --convergence [100x100x70x50x20, 1.e-6, 10] \
   --smoothing-sigmas 5x3x2x1x0vox \
   --shrink-factors 10x6x4x2x1 \
   --use-histogram-matching 1 \
   -x [ $fixed_mask, $moving_mask ] \
   --interpolation Linear \
   -o [ ${outPrefix}_xfm, ${outPrefix}_warped.nii.gz ]

#   --initial-moving-transform itk_transformation_${sbjID}.txt \


 echo  "Finished ants registration at $(date +"%T")"

# cleanup
#rm itk_transformation_${sbjID}.txt
rm itk_transformation_sub-${sbjID}.txt
#rm tmp_${sbjID}.mat
rm tmp_sub-${sbjID}.mat
#rm tmp_${sbjID}.nii.gz
rm tmp_sub-${sbjID}.nii.gz
