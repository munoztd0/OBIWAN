#!/bin/bash

subjectID=$1
runID=$2


echo "preparing glm-08 for subject ${subjectID} session ${runID}"

# directory containing template
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/GLM/GLM-08/
# output directory for the participant
outDir=/home/evapool/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-08/
# directory containing the timing input
timingDir=/home/evapool/PAVMOD/DATA/brain/MODELS/GLM-08/sub-${subjectID}/timing/

mkdir ${outDir}
outDir=/home/evapool/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-08/sub-${subjectID}
mkdir ${outDir}
outDir=/home/evapool/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-08/sub-${subjectID}/run-${runID}/
mkdir ${outDir}

###########################
# Run feat one subject one run
echo "Started FEAT 1level for run ${runID} at $(date +"%T")"
# move the template into the participant directory
level1Template=${outDir}level1_sub-${subjectID}_run-${runID}.fsf

cp ${codeDir}level1_template.fsf $level1Template

# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level1Template
sed -i 's/runYYY/'run-$runID'/g' $level1Template

feat $level1Template
echo "Finished FEAT for run ${runID} at $(date +"%T")"
