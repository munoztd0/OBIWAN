#!/bin/bash

codeDir=/home/OBIWAN/CODE/PREPROC/06-smoothing_unzip/

smoothScript=${codeDir}smoothFunctional.sh
anatomicalScript=${codeDir}anatomicalClean.sh

# loop over subjects
#group='obese2'
group='control1'
#for subjID in	00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in  00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27  28	29	30	31	32	33	
  do
  subjectID=${group}${subjID}

	# copy anatomicals to output directory
	# qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=1:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N cpAnat_${subjectID} -F "${subjectID}" ${anatomicalScript}

	# loop over sessions
	for sessionID in second #third
	do
    
    taskID='pav' # PIT hedonicreactivity

    # input directory containing unsmoothed data
    funcDir=/home/OBIWAN/DATA/STUDY/DERIVED/ICA_ANTS/sub-${subjectID}/ses-${sessionID}/func/task-${taskID}.ica/
    # output directory for preprocessed data
    outDir=/home/OBIWAN/DATA/STUDY/CLEAN/sub-${subjectID}/ses-${sessionID}/func/
    funcDav=/home/OBIWAN/DERIVATIVES/PREPROC/sub-${subjectID}/ses-${sessionID}/func/

    # make subject level directories
    mkdir -p ${outDir}
    mkdir -p ${funcDav}

    funcImage=filtered_func_data_clean_unwarped_Coreg.nii.gz

    # kernel for smoothing (FWHM = sigma*sqrt(8*ln(2)))
    smoothKern=3.39731612 # to smooth 8 mm
    # smoothKern=1.69865806013 # to smooth 4 mm

    # copy unsmoothed functionals to funcDav
    cp ${funcDir}${funcImage} ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_unsmoothedBold.nii.gz

    ###################
    # functional data: smooth and unzip

    echo "Smoothing functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

    # kernel gauss takes the sigma (not the pixel FWHM) = sigma*2.3548
    fslmaths ${funcDir}${funcImage} -kernel gauss ${smoothKern} -fmean ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold

    # copy smoothed functionals to funcDav
    cp ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz  ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

    echo "Done smoothing functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"


    echo "Expanding functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"

    # unzip for use in SPM
    gunzip -f ${outDir}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

    gunzip -f ${funcDav}sub-${subjectID}_ses-${sessionID}_task-${taskID}_smoothBold.nii.gz

    echo "Done expanding functionals for subject ${subjectID}, session ${sessionID}, task ${taskID} at $(date +"%T")"
		done

	done

done