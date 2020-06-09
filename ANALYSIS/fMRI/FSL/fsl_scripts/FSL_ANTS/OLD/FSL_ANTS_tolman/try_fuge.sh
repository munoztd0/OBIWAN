#!/bin/bash

# pull in the subject we should be working on
subjectID=08
runID=01

echo Subject: $subjectID
echo Session: $runID

echo "Preparing subject ${subjectID} session ${runID}"
# the subject directory
subT2=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T2_reoriented_brain.nii.gz
# Directory containing functionals, high-res reference scans, and field-maps
funcDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}.ica/
# Directory with run-specific files
runDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/
# the dwell time for fugue unwarping
dwellTime=0.00054


#######################
#  put EPI and fieldmaps in the same voxel space
echo "putting fieldmaps and EPI in the same space for ${subjectID} Session ${runID} at $(date +"%T")"

funcScan=${funcDir}filtered_func_data_clean
mapImage=${runDir}RUN_${runID}_rad
magImage=${runDir}RUN_${runID}_mag_brain

# we need the warped magnitude image since is more similar to the functional to realin
fugue -i ${magImage} --dwell=${dwellTime} --loadfmap=${mapImage} --unwarpdir=y --nokspace -s 0.5 -w ${magImage}_warped

# extract a single volumn for realignemnt
fslroi ${funcScan} ${funcScan}_sample 0 1

# register the magnitude image of the fieldmap acquisition to EPI to get transformation matrix
flirt -in ${magImage}_warped -ref ${funcScan}_sample -dof 6 -out ${magImage}_EPIalign -omat ${magImage}_EPIalign.mat
# apply transformation matrix to the rad image
flirt -in ${mapImage} -ref ${funcScan}_sample -init ${magImage}_EPIalign.mat -applyxfm -out ${mapImage}_EPIalign

#######################
#  unwarp the functionals
echo "Unwarping functionals for Subject ${subjectID} Session ${runID} at $(date +"%T")"

fugue -i ${funcScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y -u ${funcScan}_unwarped_corrected_3

# extract a single volumn for warped/unwarped comparison to the original T2
fslroi ${funcScan}_unwarped ${funcScan}_unwarped_sample 0 1

flirt -in ${funcScan}_sample -ref ${subT2} -dof 6 -out ${funcScan}_sample_alignT2 -omat ${funcScan}_sample_alignT2.mat
flirt -in ${funcScan}_unwarped_sample -ref ${subT2} -init ${funcScan}_sample_alignT2.mat -applyxfm -out ${funcScan}_unwarped_sample_alignT2
echo "done unwarping functional scan for Subject ${subjectID} Session ${runID} at $(date +"%T")"


#######################
#  unwarp the reference image

echo "Unwarping reference scan for Subject ${subjectID} Session ${runID} at $(date +"%T")"
refScan=${runDir}RUN_SB_${runID}_reoriented_brain_restore
mapImage=${runDir}RUN_${runID}_rad
fugue -i ${refScan} --dwell=${dwellTime} --loadfmap=${mapImage}_EPIalign --unwarpdir=y -u ${refScan}_unwarped

# save T2-aligned warped & unwarped images for comparison
flirt -in ${refScan} -ref ${subT2} -dof 6 -out ${refScan}_alignT2 -omat ${refScan}_alignT2.mat
flirt -in ${refScan}_unwarped -ref ${subT2} -init ${refScan}_alignT2.mat -applyxfm -out ${refScan}_unwarped_alignT2
echo "Done Unwarping reference for Subject ${subjectID} Session ${runID} at $(date +"%T")"
