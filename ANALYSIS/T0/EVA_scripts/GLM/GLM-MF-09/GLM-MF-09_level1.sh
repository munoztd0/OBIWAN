#!/bin/bash

subjectID=$1
runID=$2


echo "preparing GLM-MF-09 for subject ${subjectID} session ${runID}"

# directory containing template
codeDir=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/GLM/GLM-MF-09/
# output directory for the participant
outDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-MF-09/
# directory containing the timing input
timingDir=/home/eva/PAVMOD/DATA/brain/MODELS/SPM/GLM-MF-09/sub-${subjectID}/timing/
# functional data for the run
funcData=/home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subjectID}/func/sub-${subjectID}_task-Pavmod_run-${runID}_smoothBold.nii


mkdir ${outDir}
outDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-MF-09/sub-${subjectID}
mkdir ${outDir}
outDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-MF-09/sub-${subjectID}/run-${runID}/
mkdir ${outDir}

echo "output directory: ${outDir}"

###########################
# Run feat one subject one run
echo "Started FEAT 1level for run ${runID} at $(date +"%T")"
# move the template into the participant directory
level1Template=${outDir}level1_sub-${subjectID}_run-${runID}.fsf

# if run3 grab the GLM for extinction otherwise the one for learning
if [ ${runID} = 03 ]; then

  if [ ${subjectID} = 10 ] || [ ${subjectID} = 18 ] ; then # list of subject with no action for this runYYY
    cp ${codeDir}level1_template-GLM-MF-09-E-noaction.fsf $level1Template
  else
    cp ${codeDir}level1_template-GLM-MF-09-E.fsf $level1Template
  fi

elif [ ${runID} = 02 ]; then

    if [ ${subjectID} = 06 ]; then
      echo "Selecting template without action"
      cp ${codeDir}level1_template-GLM-MF-09-L-noaction.fsf $level1Template
    else
      cp ${codeDir}level1_template-GLM-MF-09-L.fsf $level1Template
    fi

elif [ ${runID} = 01 ]; then

  if [ ${subjectID} = 27 ] || [${subjectID} = 06] || [ ${subjectID} = 18 ] || [ ${subjectID} = 20 ] || [ ${subjectID} = 10 ]; then
    echo "Selecting template without action"
    cp ${codeDir}level1_template-GLM-MF-09-L-noaction.fsf $level1Template
  else
    cp ${codeDir}level1_template-GLM-MF-09-L.fsf $level1Template
  fi

fi

# correct for the number of volumes
nvols=`fslnvols ${funcData}`
echo "nvolumes is ${nvols} for images: ${funcData}"

# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level1Template
sed -i 's/runYYY/'run-$runID'/g' $level1Template
sed -i -e 's/ZZZ/'$nvols'/' $level1Template

feat $level1Template
echo "Finished FEAT for run ${runID} at $(date +"%T")"
