#!/bin/bash

# pull in the subject we should be working on
subjectID=$1

#choose task OR runID=$2
taskID=$2


echo "Preparing subject ${subjectID} session fo FMun "

home=$(eval echo ~$user)

# Directory containing functionals, high-res reference scans, and field-maps
funcDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/func/task-${taskID}.ica/

# Directory with run-specific files
runDir=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/fmap/

# the dwell time for fugue unwarping (in sec) check on procedure (its echo-spacing time not dewll time!)
dwellTime=0.00069


#Partial FOV FMRI Registration
#Partial field of view functional images: An additional step is inserted prior to step 1.
#A whole-brain functional scan with identical parameters (resolution and slice orientation)
#conducted from the partial FOV to whole-brain functional image.

#######################
# Put EPI and fieldmaps in the same voxel space
echo "putting fieldmaps and EPI in the same space for ${subjectID} Session ${runID} at $(date +"%T")"

funcScan=${funcDir}filtered_func_data_clean
mapImage=${runDir}sub-${subjectID}_ses-second_run-01_fmap_rads
magImage=${runDir}sub-${subjectID}_ses-second_run-01_fmap_mag

# we need the warped magnitude image since is more similar to the functional to realin check if y-
fugue -i ${magImage}.nii.gz --dwell=${dwellTime} --loadfmap=${mapImage} --unwarpdir=y- --nokspace -s 0.5 -w ${magImage}_warped.nii.gz

# extract mean of the functional for realignement
fslmaths ${funcScan}.nii.gz -Tmean ${funcScan}_mean.nii.gz

# perform bias correction on the mean functional
${home}/REWOD/CODE/PREPROC/04_FUGUE_Unwarping/N4BiasFieldCorrection -i ${funcScan}_mean.nii.gz -o ${funcScan}_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# perform bias correction on the magnitude image
${home}/REWOD/CODE/PREPROC/04_FUGUE_Unwarping/N4BiasFieldCorrection -i ${magImage}_warped.nii.gz -o ${magImage}_warped_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# register the magnitude image of the fieldmap acquisition to EPI to get transformation matrix by using the mag as a reference since it's better quality
flirt -in ${funcScan}_mean_bias.nii.gz -ref ${magImage}_warped_bias.nii.gz -dof 6 -cost normcorr -out ${magImage}_EPIalign.nii.gz -omat ${magImage}_EPIalign.mat

# since we used the magnitude as a reference we need to invert the transformation matrix before applying it
convert_xfm -omat ${magImage}_EPIalign_inverted.mat -inverse ${magImage}_EPIalign.mat

# apply transformation matrix to the rad image // that's the matrix we got from before
flirt -in ${mapImage}.nii.gz -ref ${funcScan}_mean_bias.nii.gz -init ${magImage}_EPIalign_inverted.mat -applyxfm -out ${mapImage}_EPIalign.nii.gz

#######################
#  unwarp the functionals
echo "Unwarping functionals for Subject ${subjectID} Session at $(date +"%T")"

fugue -i ${funcScan}.nii.gz --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y- -u ${funcScan}_unwarped.nii.gz


#######################
#  unwarp the reference image
echo "Unwarping reference scan for Subject ${subjectID} Session at $(date +"%T")"

refScan=${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjectID}/ses-second/anat/sub-${subjectID}_ses-second_run-01_sbref_reoriented_brain_restore

fugue -i ${refScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y- -u ${refScan}_unwarped
