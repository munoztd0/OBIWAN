#!/bin/bash

# pull in the subject we should be working on
#subjectID=$1
#sessionID=$2
#taskID=$3
subjectID="control125"
sessionID="second"
taskID="pavlovianlearning"

echo "Preparing subject ${subjectID} session ${sessionID} task ${taskID}"
# the subject directory
#subT2=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T2_reoriented_brain.nii.gz
subT2=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-first/anat/sub-${subjectID}_ses-first_run-01_T2_reoriented_brain.nii.gz
# Directory containing functionals, high-res reference scans, and field-maps
#funcDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}.ica/
funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/
# Directory with run-specific files
#runDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/
runDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/fmap/
# the dwell time for fugue unwarping
#dwellTime=0.00054
dwellTime=0.00036


#######################
#  put EPI and fieldmaps in the same voxel space
echo " putting fieldmaps and EPI in the same space for ${subjectID} Session ${sessionID} task ${taskID} at $(date +"%T")"

funcScan=${funcDir}filtered_func_data_clean
#mapImage=${runDir}RUN_${runID}_rad
mapImage=${runDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_fmap_rads
#magImage=${runDir}RUN_${runID}_mag_brain
magImage=${runDir}sub-${subjectID}_ses-${sessionID}_acq-task-${taskID}_magnitude1_brain

# we need the warped magnitude image since is more similar to the functional to realin
fugue -i ${magImage} --dwell=${dwellTime} --loadfmap=${mapImage} --unwarpdir=y --nokspace -s 0.5 -w ${magImage}_warped

# extract mean of the functional for realignement
fslmaths ${funcScan} -Tmean ${funcScan}_mean

# perform bias correction on the mean functional
#/usr/local/ANTs/build/bin/N4BiasFieldCorrection -i ${funcScan}_mean.nii.gz -o ${funcScan}_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]
/usr/local/ants/bin/N4BiasFieldCorrection -i ${funcScan}_mean.nii.gz -o ${funcScan}_mean_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# perform bias correction on the magnitude image
#/usr/local/ANTs/build/bin/N4BiasFieldCorrection -i ${magImage}_warped.nii.gz -o ${magImage}_warped_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]
/usr/local/ants/bin/N4BiasFieldCorrection -i ${magImage}_warped.nii.gz -o ${magImage}_warped_bias.nii.gz --convergence [100x100x100x100,0.0] -d 3 -s 3 -b [300]

# register the magnitude image of the fieldmap acquisition to EPI to get transformation matrix by using the mag as a reference since it's better quality
flirt -in ${funcScan}_mean_bias -ref ${magImage}_warped_bias -dof 6 -cost normcorr -out ${magImage}_EPIalign -omat ${magImage}_EPIalign.mat

# since we used the magnitude as a reference we need to invert the transformation matrix before applying it
convert_xfm -omat ${magImage}_EPIalign_inverted.mat -inverse ${magImage}_EPIalign.mat

# apply transformation matrix to the rad image
flirt -in ${mapImage} -ref ${funcScan}_mean_bias -init ${magImage}_EPIalign_inverted.mat -applyxfm -out ${mapImage}_EPIalign

#######################
#  unwarp the functionals
echo "Unwarping functionals for Subject ${subjectID} Session ${sessionID} task ${taskID} at $(date +"%T")"

fugue -i ${funcScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y -u ${funcScan}_unwarped

# extract a single volume for warped/unwarped comparison to the original T2
fslroi ${funcScan}_unwarped ${funcScan}_unwarped_sample 0 1
fslroi ${funcScan} ${funcScan}_sample 0 1

flirt -in ${funcScan}_sample -ref ${subT2} -dof 6 -out ${funcScan}_sample_alignT2 -omat ${funcScan}_sample_alignT2.mat
flirt -in ${funcScan}_unwarped_sample -ref ${subT2} -init ${funcScan}_sample_alignT2.mat -applyxfm -out ${funcScan}_unwarped_sample_alignT2
echo "done unwarping functional scan for Subject ${subjectID} Session ${sessionID} task ${taskID} at $(date +"%T")"


#######################
#  unwarp the reference image

#echo "Unwarping reference scan for Subject ${subjectID} Session ${sessionID} task ${taskID} at $(date +"%T")"
#refScan=${runDir}RUN_SB_${runID}_reoriented_brain_restore
#refScan=${runDir}RUN_SB_${runID}_reoriented_brain
#refScan=${runDir}RUN_SB_${runID}_reoriented_brain_restore

#mapImage=${runDir}RUN_${runID}_rad
#fugue -i ${refScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y -u ${refScan}_unwarped

# save T2-aligned warped & unwarped images for comparison
#flirt -in ${refScan} -ref ${subT2} -dof 6 -out ${refScan}_alignT2 -omat ${refScan}_alignT2.mat
#flirt -in ${refScan}_unwarped -ref ${subT2} -init ${refScan}_alignT2.mat -applyxfm -out ${refScan}_unwarped_alignT2
#echo "Done Unwarping reference for Subject ${subjectID} Session ${runID} task ${taskID} at $(date +"%T")"
