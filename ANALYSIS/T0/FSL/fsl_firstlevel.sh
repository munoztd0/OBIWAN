#!/bin/bash

# pull in the subject we should be working on
subjectID=$1

#choose task OR runID=$2
taskID=$2

#choose session OR runID=$2
sessionID=$3

#chooseGLM OR runID=$2
glmID=$4


##echo "Preparing subject ${subjectID} session ${taskID}"
echo "Preparing subject ${subjectID} session ${sessionID}"

home=$(eval echo ~$user)

# Directory containing prepped nifti data
dataDir=${home}/OBIWAN/DERIVATIVES/PREPROC/sub-${subjectID}/ses-${sessionID}/func/

codeDir=${home}/OBIWAN/CODE/ANALYSIS/fMRI/FSL/

# Output directory for preprocessed files
outDir=${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/${glmID}/sub-${subjectID}/timing/

mkdir ${outDir}


###########################
# task GLM
echo "Started GLM ${glmID} for subj ${subjectID} for session ${taskID} at $(date +"%T")"

# create a template name for subject and task
GLM_tmp=${outDir}GLM_sub-${subjectID}_ses-${sessionID}_task-${taskID}.fsf

# move the template into the task directory
cp ${codeDir}${taskID}.fsf ${GLM_tmp} #check

# carve in subject specific numbers using wildcards
sed -i -e 's/subXXX/'$subjectID'/g' ${GLM_tmp}

# carve in task specific numbers using wildcards
sed -i -e 's/sesYYY/'$sessionID'/g' ${GLM_tmp}

# carve in task specific numbers using wildcards
sed -i -e 's/glmUUU/'$glmID'/g' ${GLM_tmp}

# carve in home #change \ by |
sed -i -e "s|homeOOO|$home|" ${GLM_tmp}



# carve in nvols specific numbers using wildcards
nvols=`fslnvols ${dataDir}*task-${taskID}_smoothBold.nii`
sed -i -e 's/ZZZ/'$nvols'/' ${GLM_tmp}
echo ${nvols}

# carve in nvoxs specific numbers using wildcards
# firt output is <voxels> second is <volumes>, this just takes the first input
arr=`fslstats ${dataDir}*task-${taskID}_smoothBold.nii -v`
nvoxs=$(echo ${arr} | cut -d " " -f 1)
sed -i -e 's/WWW/'$nvoxs'/' ${GLM_tmp}
echo ${nvoxs}

# task the template into FEAT
feat ${GLM_tmp}

#hacking FSL to think we did the reg in FSL but we did it with ANTS ahaha dumb FSL.. ok I need to sleep ..
#cp -r ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output+.feat/reg ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat/
rm ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat/reg/*.mat

cp $FSLDIR/etc/flirtsch/ident.mat ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat/reg/example_func2standard.mat
cp ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat/mean_func.nii.gz ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat/reg/standard.nii.gz

mv ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/output.feat ${home}/OBIWAN/DERIVATIVES/GLM/FSL/${taskID}/$glmID/sub-${subjectID}/first.feat
echo "Finished GLM ${glmID} for subj ${subjectID} for session ${taskID} at $(date +"%T")"
