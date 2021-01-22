#!/bin/bash
home=$(eval echo ~$user);

task="PIT"
GLM="GLM_01_X"
codeDir="/home/OBIWAN/CODE/ANALYSIS/fMRI/SPM/${task}/"
matlab_script="${GLM}_stLevel"
#matlab_script="tstats_mvpa_04"
#matlab_script="beta_mvpa_04"
matlabSubmit="${home}/OBIWAN/CODE/ANALYSIS/fMRI/dependencies/matlab_oneSubj.sh"

#which group
#group='control1'
group='obese2'

# Loop over subjects
# Loop over control1: 00	02	05	06	07	08	09	10	12	13	14	15	16	18	19	20	21	22	25	26	27	28	29	30	31	32	33
#obese2: 00	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
 #missing 43 55 57 60

for subjID in 00 01 #	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
do
	subj=$(eval echo ${group}${subjID})
	# prep for each session's data
	qsub -o ${home}/OBIWAN/ClusterOutput -j oe -l walltime=4:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m n -l nodes=1  -q queue1 -N ${subjID}_${GLM} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

done
