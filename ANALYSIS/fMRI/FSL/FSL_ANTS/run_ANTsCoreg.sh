#!/bin/bash

# #############
# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/

# script to run
funcScript=${codeDir}ANTsCoregRefAndFunc.sh
anatScript=${codeDir}ANTsCoregAnatomical.sh

# Loop over subjects
# e.g: for subj in 001 002
for subj in 11 # 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	# co-register the anatomicals for comparison
	# qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=0:05:00,pmem=1GB -M evapool@caltech.edu -m e -q batch -N warpAnatomical_Sub_${subj} -F "${subj}" ${anatScript}

	for runID in 01 02 03
	do
		qsub -o ~/ClusterOutput -j oe -l nodes=1,walltime=01:00:00,pmem=5GB -M evapool@caltech.edu -m e -q batch -N warpFuncT2_Sub_${subj}_Run_${runID} -F "${subj} ${runID}" ${funcScript}
	done
done

# merge all anatomicals together into a single image file
# outDir=/home/jcockburn/casino_fMRI/neuralPreProcessing/ICA_ANTs/
# mergedImage=${outDir}allSampleFunc_T2CoReg.nii.gz
# # add the standard space T2 as the initial image
# cp ${codeDir}CIT168_T2w_MNI_lowres.nii.gz ${mergedImage}
# cpString=${mergedImage}

# # 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
# for subj in 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
# do
# 	for runID in 1 2 3 4
# 	do
# 		# where the functional sample file is saved

# 		if [[ "${subj}" = "103" && "${runID}" = "1" ]] || [[ "${subj}" = "104" && "${runID}" = "4" ]]; then
# 			echo "skipped: sub ${subj} run ${runID}"
# 		else
# 			echo "appending: sub ${subj} run ${runID}"
# 			cpString="${cpString} /home/jcockburn/casino_fMRI/neuralPreProcessing/ICA_ANTs/sub${subj}/Session${runID}.ica/func_sample_ANTsFuncT2.nii.gz"
# 		fi

# 	done
# done

# # echo ${cpString}
# align funcitonals to get a measure of shift across subjects
# fslmerge -t ${mergedImage} ${cpString}
# mcflirt -in ${mergedImage} -refvol 0 -report -plots -out ${mergedImage}_mcf
