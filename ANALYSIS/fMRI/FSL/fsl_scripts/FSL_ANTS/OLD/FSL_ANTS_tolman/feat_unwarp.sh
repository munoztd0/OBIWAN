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
outDir=/home/evapool/PAVMOD/DATA/brain/tmp/${subjectID}/RUN_${runID}.ica/
# Output directory for preprocessed files
FmDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/

mkdir -p ${outDir}

###########################
# Run FEAT template to for the fieldmaps unwarping: approx 4 hours for 960 volumns

# bias correct the magnitude images of the fieldmaps to improve registration
echo "Running bias correction on magnitude image $(date +"%T")"
# magn image
/usr/local/ANTs/build/bin/N4BiasFieldCorrection -i ${FmDir}RUN_${runID}_mag.nii.gz -o ${FmDir}RUN_${runID}_bias_mag.nii.gz --convergence [100x100x100x100,0.0] -d 3
# brain extrated magn image
/usr/local/ANTs/build/bin/N4BiasFieldCorrection -i ${FmDir}RUN_${runID}_mag_brain.nii.gz -o ${FmDir}RUN_${runID}_bias_mag_brain.nii.gz --convergence [100x100x100x100,0.0] -d 3


echo "Started FEAT for run ${runID} at $(date +"%T")"
# move the template into the run directory
featUnwarpTemplate=${outDir}FEAT_sub${subjectID}_run${runID}.fsf
cp ${codeDir}FMUNWARP.fsf $featUnwarpTemplate
# carve in subject/run specific numbers
sed -i -e 's/subXXX/'$subjectID'/g' $featUnwarpTemplate
sed -i -e 's/RUNYYY/'$runID'/g' $featUnwarpTemplate
# correct the number of volumes if necessary
nvols=`fslnvols ${dataDir}/NIFTI/*.nii.gz`
echo ${nvols}
sed -i -e 's/ZZZ/'$nvols'/' $featUnwarpTemplate
# run the template
feat $featUnwarpTemplate
echo "Finished FEAT for run ${runID} at $(date +"%T")"
