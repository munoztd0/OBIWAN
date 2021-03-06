#!/bin/bash


dataDir="/home/OBIWAN/DATA/STUDY/DERIVED/PIT_HEDONIC/"
codeDir="/home/OBIWAN/ANALYSIS/spm_scripts/"
sessionID="second"

# Loop over subjects

for subjID in obese226 obese227 
do
	# unzip functional
	for runID in PIT pavlovianlearning hedonicreactivity
	do
		# unzip for use in SPM
		 echo "Expanding functionals Subject ${subjID} Run ${runID} at $(date +"%T")"
		 gunzip -f ${dataDir}sub-${subjID}/ses-${sessionID}/func/sub-${subjID}_ses-${sessionID}_task-${runID}_run-01_bold.nii.gz
		 echo "Done expanding functional Subject ${subjID} Session ${runID} at $(date +"%T")"
	done

  # unzip anatomical
	  echo "Expanding anatomicals Subject ${subjID} at $(date +"%T")"
		gunzip -f ${dataDir}sub-${subjID}/ses-first/anat/sub-${subjID}_ses-first_run-01_T1.nii.gz
		echo "Done expanding anatomical Subject ${subjID} at $(date +"%T")"
done
