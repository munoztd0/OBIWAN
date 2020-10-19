#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
runID=$2
sessionID=$3
echo "Preparing subject ${subjectID} task ${runID} session ${sessionID}"

# directory containing scripts and templates
codeDir=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/
# Directory containing prepped nifti data
dataDir=/home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subjectID}/ses-${sessionID}/func/
# Output directory for preprocessed files
outDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/

mkdir ${outDir}


###########################
# Run MELODIC template: approx 4 hours for 960 volumns
echo "Started MELODIC for run ${runID} at $(date +"%T")"
# move the template into the run directory
melodicTempplate=${outDir}ICA_sub-${subjectID}_ses-${sessionID}_task-${runID}.fsf
cp ${codeDir}ICA.fsf $melodicTempplate
# carve in subject/run specific numbers
sed -i -e 's/subXXX/'$subjectID'/g' $melodicTempplate
sed -i -e 's/RUNYYY/'$runID'/g' $melodicTempplate
sed -i -e 's/sesWWW/'$sessionID'/g' $melodicTempplate
# correct the number of volumes if necessary
nvols=`fslnvols ${dataDir}*task-${runID}_run-01_bold.nii.gz`
echo ${nvols}
sed -i -e 's/ZZZ/'$nvols'/' $melodicTempplate
# run the template
feat $melodicTempplate
echo "Finished MELODIC for run ${runID} at $(date +"%T")"
