#!/bin/bash

# pull in the subject we should be working on
subjectID=$1
runID=$2
echo "Preparing subject ${subjectID}: run ${runID} for FEAT"

# directory containing fsl scripts and templates
codeDir=/home/evapool/PAVMOD/ANALYSIS/fsl_script/FSL_ANTS_tolman/
# Directory containing nifti data
dataDir=/home/evapool/PAVMOD/DATA/brain/population/${subjectID}/
# Output directory for preprocessed files
outDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/

# make the subject level directory
mkdir ${outDir}

###################
# Field map generation -  takes 5-10 min
# Expects files named pos_Session<runID> and neg_Session<runID>
# generates megnitude and radian files Session<runID>_mag and Session<runID>_rad for unwarping
echo "started building fieldmaps at for session ${runID} at $(date +"%T")"
# reorient the pos/neg images, and merge into a single image
fslreorient2std ${dataDir}fmap_pos_${runID}/NIFTI/*nii.gz ${outDir}fmap_pos_${runID}_reoriented
fslreorient2std ${dataDir}fmap_neg_${runID}/NIFTI/*nii.gz ${outDir}fmap_neg_${runID}_reoriented
mergedFM=${outDir}FM_RUN_${runID}_merged
fslmerge -t $mergedFM ${outDir}fmap_pos_${runID}_reoriented ${outDir}fmap_neg_${runID}_reoriented
# Run TOPUP to generate fieldmap
# requires fieldmaps_datain.txt to specify the map parameters
topup --imain=${mergedFM} --datain=${codeDir}fieldmaps_datain.txt --config=b02b0.cnf --fout=${outDir}FM_RUN_${runID} --iout=${mergedFM}_unwarped
# Scale fieldmap to convert from Hz to rad/s
fslmaths ${outDir}FM_RUN_${runID} -mul 6.28 ${outDir}RUN_${runID}_rad
# compute field magnitude, and extract brain
fslmaths ${mergedFM}_unwarped -Tmean ${outDir}RUN_${runID}_mag
bet ${outDir}RUN_${runID}_mag ${outDir}RUN_${runID}_mag_brain -f 0.25 -R
echo "Done building fieldmaps at for session ${runID} at $(date +"%T")"


###################
# high-res reference image
# extract brain from reference scan and bias correct
# generates bias corrected and brain exracted file ref_Session<runID>_reoriented_brain (single band reference image for the session)
echo "Started on reference scan for run ${runID} at $(date +"%T")"
fslreorient2std ${dataDir}RUN_SB_${runID}/NIFTI/*nii.gz ${outDir}RUN_SB_${runID}_reoriented
bet ${outDir}RUN_SB_${runID}_reoriented ${outDir}RUN_SB_${runID}_reoriented_brain -f 0.25 -R
# segment and bias correct the extracted brain
fast -n 4 -t 2 -B --out=${outDir}RUN_SB_${runID}_reoriented_brain ${outDir}RUN_SB_${runID}_reoriented_brain
echo "Done reference scan for run ${runID} at $(date +"%T")"
# Delete unnecessary files
rm "${outDir}"*_seg*
rm "${outDir}"*_pve*
rm "${outDir}"*_mixeltype*

###################
# functional data
# reorient and extract brain
# generates Session<runID>_reoriented_brain
echo "Started reorientation on functional scans for run ${runID} at $(date +"%T")"
fslreorient2std ${dataDir}RUN_${runID}/NIFTI/*nii.gz ${outDir}RUN_${runID}_reoriented
bet ${outDir}RUN_${runID}_reoriented ${outDir}RUN_${runID}_reoriented_brain -f 0.25 -R
echo "Done reorientation and extraction on functional for run ${run} at $(date +"%T")"
