
# set this to the directory containing antsRegistration
#ANTSPATH=/usr/local/ANTs/build/bin/
ANTSPATH=/usr/local/ants/bin/

# ITK thread count
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

# Check args
if [ $# -lt 1 ]; then
echo "USAGE: $0 <sbj>"
  exit
fi

sbj=$1
echo Sbject: $sbj

# path to afine transform tool
#c3d_affine_tool=/usr/local/c3d/c3d-1.0.0-Linux-x86_64/bin/c3d_affine_tool
c3d_affine_tool=/usr/local/c3d-1.1.0-Linux-gcc64/bin/c3d_affine_tool
# path to the warp tool
#warpTool=/usr/local/ANTs/build/bin/WarpImageMultiTransform
warpTool=/usr/local/ants/bin/WarpImageMultiTransform
# paths to the T1/T2 structurals, and the standard anatomical images
#subAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${sbj}/
subAnatDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${sbj}/ses-first/anat/
#standardAnatDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/
standardAnatDir=/home/OBIWAN/DATA/CANONICALS/

# align the T1 and T2 anatomicals and downsample to functional resolution
#codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS/
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/
fixedT1=CIT168_T1w_MNI
fixedT2=CIT168_T2w_MNI
echo "Running Flirt to downsample T1 & T2 $(date +"%T")"
flirt -ref ${standardAnatDir}${fixedT1} -in ${standardAnatDir}${fixedT1} -out ${standardAnatDir}${fixedT1}_lowres -applyisoxfm 2.5 -omat ${standardAnatDir}${fixedT1}_lowres.mat
flirt -ref ${standardAnatDir}${fixedT2} -in ${standardAnatDir}${fixedT2} -out ${standardAnatDir}${fixedT2}_lowres -applyisoxfm 2.5 -omat ${standardAnatDir}${fixedT2}_lowres.mat
echo "Done Flirt to downsample T1 & T2 $(date +"%T")"


#############
# Define target space (fixed) T1/T2 & masks file names
fixed_T1=${standardAnatDir}CIT168_T1w_MNI.nii.gz
fixed_T2=${standardAnatDir}CIT168_T2w_MNI.nii.gz
fixed_T2lowres=${standardAnatDir}CIT168_T2w_MNI_lowres.nii.gz
fixed_T1lowres=${standardAnatDir}CIT168_T1w_MNI_lowres.nii.gz
fixed_mask=${standardAnatDir}`basename ${fixed_T1} .nii.gz`_mask.nii.gz
# Define subject images (moving) T1/T2 & masks file names
#moving_T1=${subAnatDir}T1_reoriented_brain
moving_T1=${subAnatDir}sub-${sbj}_ses-first_run-01_T1_reoriented_brain
#moving_T2=${subAnatDir}T2_reoriented_brain_aligned_T1
moving_T2=${subAnatDir}sub-${sbj}_ses-first_run-01_T2_reoriented_brain_aligned_T1
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

# apply warp to the T2 (which is T1 aligned) anatomical (check coreg quality)
echo "Apply ANTs warp to T2 at $(date +"%T")"
#${warpTool} 3 ${moving_T2} ${subAnatDir}T2_reoriented_brain_ANTsCoreg.nii.gz \
${warpTool} 3 ${moving_T2} ${subAnatDir}sub-${sbj}_ses-first_run-01_T2_reoriented_brain_ANTsCoreg.nii.gz \
	-R ${fixed_T2lowres} \
	${outPrefix}_xfm1Warp.nii.gz ${outPrefix}_xfm0GenericAffine.mat
echo "Done ANTs warp to T2 at $(date +"%T")"


# apply warp to the T1 anatomical (also check coreg quality)
echo "Apply ANTs wrap to T1 at $(date +"%T")"
#${warpTool} 3 ${moving_T1} ${subAnatDir}T1_reoriented_brain_ANTsCoreg.nii.gz \
${warpTool} 3 ${moving_T1} ${subAnatDir}sub-${sbj}_ses-first_run-01_T1_reoriented_brain_ANTsCoreg.nii.gz \
        -R ${fixed_T1lowres} \
        ${outPrefix}_xfm1Warp.nii.gz ${outPrefix}_xfm0GenericAffine.mat
echo "Done ANTs warp to T1 at $(date +"%T")"


# resample the original so it can be compared
echo "resample the original so it can be compared $(date +"%T")"
flirt -in ${moving_T1}.nii.gz -ref ${fixed_T2lowres} -dof 6 -out ${moving_T1}_standardAlign
flirt -in ${moving_T2}.nii.gz -ref ${fixed_T2lowres} -dof 6 -out ${moving_T2}_standardAlign
echo "done resampling original $(date +"%T")"
