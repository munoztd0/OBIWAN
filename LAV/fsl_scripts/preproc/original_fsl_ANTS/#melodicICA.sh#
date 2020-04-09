#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
runID=$2
echo "Preparing subject ${subjectID} session ${runID}"

# directory containing scripts and templates
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
# Directory containing prepped nifti data
dataDir=/home/evapool/PAVMOD/DATA/brain/population/${subjectID}/RUN_${runID}/
# Output directory for preprocessed files
outDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/

mkdir ${outDir}


###########################
# Run MELODIC template: approx 4 hours for 960 volumns
echo "Started MELODIC for run ${runID} at $(date +"%T")"
# move the template into the run directory
melodicTempplate=${outDir}ICA_sub${subjectID}_run${runID}.fsf
cp ${codeDir}ICA.fsf $melodicTempplate
# carve in subject/run specific numbers
sed -i -e 's/subXXX/'$subjectID'/g' $melodicTempplate
sed -i -e 's/RUNYYY/'$runID'/g' $melodicTempplate
# correct the number of volumes if necessary
nvols=`fslnvols ${dataDir}/NIFTI/*.nii.gz`
echo ${nvols}
sed -i -e 's/ZZZ/'$nvols'/' $melodicTempplate
# run the template
feat $melodicTempplate
echo "Finished MELODIC for run ${runID} at $(date +"%T")"
