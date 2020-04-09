#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
sessionID=$2
taskID=$3
#subjectID="control125"
#sessionID="second"
#taskID="pavlovianlearning"

echo "Preparing subject ${subjectID} session ${sessionID} task ${taskID}"

# subject directory
subT2=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/sub-${subjectID}_ses-first_run-01_T2_reoriented_brain.nii.gz
# directory containing functionals and fieldmaps
funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/
# directory with run-specific files
runDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/fmap/
# dwell time for fugue unwarping (EffectiveEchoSpacing for EPI in json)
dwellTime=0.00036


#######################
# put EPI and fieldmaps in the same voxel space
echo "Putting fieldmaps and EPI in the same space for subject ${subjectID} session ${sessionID} task ${taskID} at $(date +"%T")"

funcScan=${funcDir}filtered_func_data_clean
mapImage=${runDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_fmap_rads
magImage=${runDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain

# we need the warped magnitude image since it's more similar to the functional to realign (watch out for unwarpdir: must be the SAME as for functional unwarping)
fugue -i ${magImage} --dwell=${dwellTime} --loadfmap=${mapImage} --unwarpdir=y- --nokspace -s 0.5 -w ${magImage}_warped

# extract mean of the functional for realignement
fslmaths ${funcScan} -Tmean ${funcScan}_mean

# perform bias correction on the mean functional
/usr/local/ants/bin/N4BiasFieldCorrection -i ${funcScan}_mean.nii.gz -o ${funcScan}_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# perform bias correction on the magnitude image
/usr/local/ants/bin/N4BiasFieldCorrection -i ${magImage}_warped.nii.gz -o ${magImage}_warped_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# register the magnitude image of the fieldmap acquisition to EPI to get transformation matrix by using the mag as a reference since it's better quality
flirt -in ${funcScan}_mean_bias -ref ${magImage}_warped_bias -dof 6 -cost normcorr -out ${magImage}_EPIalign -omat ${magImage}_EPIalign.mat

# since we used the magnitude as a reference we need to invert the transformation matrix before applying it
convert_xfm -omat ${magImage}_EPIalign_inverted.mat -inverse ${magImage}_EPIalign.mat

# apply transformation matrix to the rad image
flirt -in ${mapImage} -ref ${funcScan}_mean_bias -init ${magImage}_EPIalign_inverted.mat -applyxfm -out ${mapImage}_EPIalign

#######################
# Unwarp functionals
echo "Unwarping functionals for subject ${subjectID} session ${sessionID} task ${taskID} at $(date +"%T")"

# watch out for unwarpdir: must be the SAME as for magnitude warping
fugue -i ${funcScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y- -u ${funcScan}_unwarped

# extract a single volume for warped/unwarped comparison to the original T2
fslroi ${funcScan}_unwarped ${funcScan}_unwarped_sample 0 1
fslroi ${funcScan} ${funcScan}_sample 0 1

flirt -in ${funcScan}_sample -ref ${subT2} -dof 6 -out ${funcScan}_sample_alignT2 -omat ${funcScan}_sample_alignT2.mat
flirt -in ${funcScan}_unwarped_sample -ref ${subT2} -init ${funcScan}_sample_alignT2.mat -applyxfm -out ${funcScan}_unwarped_sample_alignT2
echo "Done unwarping functional scan for subject ${subjectID} session ${sessionID} task ${taskID} at $(date +"%T")"
