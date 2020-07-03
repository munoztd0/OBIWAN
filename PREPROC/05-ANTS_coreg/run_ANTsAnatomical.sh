#!/bin/bash

# #############
codeDir=/home/OBIWAN/CODE/PREPROC/05-ANTS_coreg/

# # re-slice target anatomical T1/T2 to match subject (moving) image resolution
# # This only needs to be done once for the whole project
# tmpDir=/home/OBIWAN/DERIVATIVES/EXTERNALDAT/CANONICALS/
# fixedT1=CIT168_T1w_MNI
# fixedT2=CIT168_T2w_MNI
# echo "Running Flirt to downsample T1 & T2 $(date +"%T")"
# flirt -ref ${tmpDir}${fixedT1} -in ${tmpDir}${fixedT1} -out ${tmpDir}${fixedT1}_lowres -applyisoxfm 2.5 -omat ${tmpDir}${fixedT1}_lowres.mat
# flirt -ref ${tmpDir}${fixedT2} -in ${tmpDir}${fixedT2} -out ${tmpDir}${fixedT2}_lowres -applyisoxfm 2.5 -omat ${tmpDir}${fixedT2}_lowres.mat
# echo "Done Flirt to downsample T1 & T2 $(date +"%T")"

# script to run #takes a looooong time
subScript=${codeDir}ANTsAnatomicalWarp.sh

# loop over subjects
group='control1'
#group='obese2'
#for subjID in	00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	#25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 00 #01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
  do
  subj=${group}${subjID}

	qsub -o /home/OBIWAN/ClusterOutput -j oe -l walltime=12:00:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ANTs_${subj}_anat -F "${subj}" ${subScript}

done
