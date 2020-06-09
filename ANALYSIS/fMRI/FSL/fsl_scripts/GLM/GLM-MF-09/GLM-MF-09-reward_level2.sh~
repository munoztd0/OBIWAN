#!/bin/bash

subjectID=$1

echo "preparing glm-09 second level for subject ${subjectID}"

# directory containing template
codeDir=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/GLM/GLM-MF-09/
# output directory for the participant
outDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/GLM-MF-09/sub-${subjectID}/
# directory with the "fake" registration
regDir=/home/eva/PAVMOD/DATA/brain/MODELS/FSL/GLM/tricks/reg


###########################
# Run feat one subject one run
echo "Started FEAT 1level for run ${runID} at $(date +"%T")"

# move the template into the participant directory
level2Template=${outDir}level2-reward_sub-${subjectID}.fsf

# grab the template with one or three run according to the participant
if [ ${subjectID} = 14 ]; then
  cp ${codeDir}level2_template_GLM-MF-09-reward-1run.fsf $level2Template
elif [ ${subjectID} = 06 ] || [ ${subjectID} = 10 ] || [ ${subjectID} = 18 ] || [ ${subjectID} = 20 ] || [ ${subjectID} = 27 ]; then
  cp ${codeDir}level2_template_GLM-MF-09-reward-noaction.fsf $level2Template
else
  cp ${codeDir}level2_template_GLM-MF-09-reward.fsf $level2Template
fi

# copy the reg directory in the participant feats (registration done with ants)
for session in 01 02 03
do
    cp -a ${regDir} ${outDir}run-${session}.feat/
done



# carve in the subject/run specific numbers
sed -i 's/subXXX/'sub-$subjectID'/g' $level2Template

feat $level2Template
echo "Finished second level FEAT at $(date +"%T")"
