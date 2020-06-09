#!/bin/bash

subjectID=$1

echo "preparing glm-08 second level for subject ${subjectID}"

# directory containing template
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/GLM/GLM-08/
# output directory for the participant
outDir=/home/evapool/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-08/sub-${subjectID}/
# directory with the "fake" registration
regDir=/home/evapool/PAVMOD/DATA/brain/MODELS/FSL/tricks/reg


###########################
# Run feat one subject one run
echo "Started FEAT 1level for run ${runID} at $(date +"%T")"

# move the template into the participant directory
level2Template=${outDir}level2_sub-${subjectID}.fsf
cp ${codeDir}level2_template.fsf $level2Template

# copy the reg directory in the participant feats

for session in 01 02
  do
    cp -a ${regDir} ${outDir}run-${session}.feat/
done

# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level2Template

feat $level2Template
echo "Finished second level FEAT at $(date +"%T")"
