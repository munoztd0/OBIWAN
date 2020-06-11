#!/bin/bash

subjectID=$1

echo "preparing glm-09 second level for subject ${subjectID}"

# directory containing template
codeDir=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/GLM/GLM-MF-19/
# output directory for the participant
outDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-MF-19/sub-${subjectID}/
# directory with the "fake" registration
regDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/tricks/reg


###########################
# Run feat for constrasts on 3 runs
echo "Started FEAT 2level for value at $(date +"%T")"

# move the template into the participant directory
level2Template=${outDir}level2-value_sub-${subjectID}.fsf

# grab the template with one or three run according to the participant
if [ ${subjectID} = 14 ]; then
  cp ${codeDir}level2_template_GLM-MF-19-value-2runs.fsf $level2Template
else
  cp ${codeDir}level2_template_GLM-MF-19-value.fsf $level2Template
fi

# copy the reg directory in the participant feats (do not copy run2 for subject 14)
for session in 01 02 03
do
  cp -a ${regDir} ${outDir}run-${session}.feat/
done


# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level2Template

feat $level2Template
echo "Finished second level FEAT at $(date +"%T")"

###########################
# Run feat for constrasts on 2 runs
echo "Started FEAT 2level for reward at $(date +"%T")"

# move the template into the participant directory
level2Template=${outDir}level2-value_sub-${subjectID}.fsf

# grab the template with one or three run according to the participant
if [ ${subjectID} = 14 ]; then
  cp ${codeDir}level2_template_GLM-MF-19-reward-1run.fsf $level2Template
else
  cp ${codeDir}level2_template_GLM-MF-19-reward.fsf $level2Template
fi

# copy the reg directory in the participant feats (do not copy run2 for subject 14)
for session in 01 02 03
do
  cp -a ${regDir} ${outDir}run-${session}.feat/
done


# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level2Template

feat $level2Template
echo "Finished second level FEAT at $(date +"%T")"
