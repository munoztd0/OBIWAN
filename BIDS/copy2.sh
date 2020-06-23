#!/bin/bash

home=$(eval echo ~$user)/OBIWAN

#small script to move and copy files

#subjID=$1
ses='second'
group='control1'
#group='obese2'
#for subjID in	00 01 02 03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70
for subjID in 00 #01 02 03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33 #00 01	02
  do  
  for file in ${home}/sub-${group}${subjID}/ses-${ses}/func/*pavlovianlearning*; do mv -f $file ${file//pavlovianlearning/inst} ; done
  for file in ${home}/sub-${group}${subjID}/ses-${ses}/func/*instrumentallearning* ; do mv -f $file ${file//instrumentallearning/pav} ; done
  for file in ${home}/sub-${group}${subjID}/ses-${ses}/fmap/*pavlovianlearning*; do mv -f $file ${file//pavlovianlearning/inst} ; done
  for file in ${home}/sub-${group}${subjID}/ses-${ses}/fmap/*instrumentallearning* ; do mv -f $file ${file//instrumentallearning/pav} ; done
done


  # for file in ${home}/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-${ses}/func/*pavlovianlearning*; do mv -f $file ${file//pavlovianlearning/inst} ; done
  # for file in ${home}/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-${ses}/func/*instrumentallearning* ; do mv -f $file ${file//instrumentallearning/pav} ; done
  # for file in ${home}/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-${ses}/fmap/*pavlovianlearning* ; do mv -f $file ${file//pavlovianlearning/inst} ; done
  # for file in ${home}/DATA/STUDY/RAW/BIDS/sub-${group}${subjID}/ses-${ses}/fmap/*instrumentallearning* ; do mv -f $file ${file//instrumentallearning/pav} ; done
# f

#funcDir=${home}/DATA/STUDY/DERIVED/ICA_ANTS/sub-${group}${subjID}/ses-second/func/task-${taskID}.ica/
#anatDir=${home}/DATA/STUDY/DERIVED/ICA_ANTS/sub-${group}${subjID}/ses-first/anat/
#outDir=${home}/DATA/STUDY/CLEAN/sub-${group}${subjID}/

#funcImage=filtered_func_data_clean_unwarped_Coreg
#funcImage=sub-${group}${subjID}_ses-${sessionID}_task-${taskID}_run-01_bold_reoriented_brain_unwarped_Coreg



# group='obese2'  
# for subjID in	03	04	05	06	07	08	09	10	11	12	13	14	15 16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	44	45	46	47	48	49	50	51	52	53	54	56	58	59	61	62	63	64	65	66	67	68	69	70

#group='control1'
#for subjID in 00 #01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33
  #do 
    #for taskID in hedonicreactivity PIT
		    #do

    #cp -r -n ${home}/DATA/STUDY/DERIVED/PIT_HEDONIC/* ${home}/DERIVATIVES/PREPROC/
    #rm -r ${home}/DERIVATIVES/PREPROC/sub*/ses-third/fmap_old
    


# log:

#mkdir -p ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-first/anat/*.json ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/
#mkdir -p ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/func/*.json ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/func/*.tsv ${home}/OBIWAN/sub-${group}${subjID}/ses-second/func/
#sub-${group}${subjID}_ses-second_acq-task-hedonicreactivity_magnitude1.nii.gz
#sub-${group}${subjID}_ses-second_run-01_magnitude.nii.gz
#cp ${home}/OBIWAN/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-first/anat/*.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/
#pydeface  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T1.nii.gz
#pydeface  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T2.nii.gz
#rm  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T1.nii.gz
#rm  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_T2.nii.gz
#mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T1_defaced.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T1w.nii.gz
#mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T2_defaced.nii.gz ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T2w.nii.gz
#mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T1.json ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T1w.json
#mv  ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/*_run-01_T2.json ${home}/OBIWAN/sub-${group}${subjID}/ses-first/anat/sub-${group}${subjID}_ses-first_run-01_T2w.json

    # DIR_second=${home}/DATA/STUDY/RAW/BEHAVIORAL/${group}${subjID}/second/
    # if [ -d "$DIR_second" ]; then
    #   mkdir -p ${home}/SOURCEDATA/behav/${group}${subjID}/ses-second
    #   cp -r ${home}/DATA/STUDY/RAW/BEHAVIORAL/${group}${subjID}/second/* ${home}/SOURCEDATA/behav/${group}${subjID}/ses-second/
    # fi

    # DIR_third=${home}/DATA/STUDY/RAW/BEHAVIORAL/${group}${subjID}/third/
    # if [ -d "$DIR_third" ]; then
    #   mkdir -p ${home}/SOURCEDATA/behav/${group}${subjID}/ses-third
    #   cp -r ${home}/DATA/STUDY/RAW/BEHAVIORAL/${group}${subjID}/third/* ${home}/SOURCEDATA/behav/${group}${subjID}/ses-third/
    # fi

    # DIR_second=${home}/DATA/STUDY/RAW/PHYSIOLOGICAL/${group}${subjID}/second/
    # if [ -d "$DIR_second" ]; then
    #   mkdir -p ${home}/SOURCEDATA/physio/${group}${subjID}/ses-second
    #   cp -r ${home}/DATA/STUDY/RAW/PHYSIOLOGICAL/${group}${subjID}/second/* ${home}/SOURCEDATA/physio/${group}${subjID}/ses-second/
    # fi

    # DIR_third=${home}/DATA/STUDY/RAW/PHYSIOLOGICAL/${group}${subjID}/third/
    # if [ -d "$DIR_third" ]; then
    #   mkdir -p ${home}/SOURCEDATA/physio/${group}${subjID}/ses-third
    #   cp -r ${home}/DATA/STUDY/RAW/PHYSIOLOGICAL/${group}${subjID}/third/* ${home}/SOURCEDATA/physio/${group}${subjID}/ses-third/
    # fi

    # DIR_third=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/
    # if [ -d "$DIR_third" ]; then
    #   mkdir -p ${home}/sub-${group}${subjID}/ses-third/func
    #   cp -r ${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/func/* ${home}/sub-${group}${subjID}/ses-third/func/
    # fi


    # DIR_first=${home}/SOURCEDATA/brain/${group}${subjID}/first/
    # if [ -d "$DIR_first" ]; then
    #   mv ${home}/SOURCEDATA/brain/${group}${subjID}/first/ ${home}/SOURCEDATA/brain/${group}${subjID}/ses-first/
    # fi

    # DIR_second=${home}/SOURCEDATA/brain/${group}${subjID}/second/
    # if [ -d "$DIR_second" ]; then
    #   mv ${home}/SOURCEDATA/brain/${group}${subjID}/second/ ${home}/SOURCEDATA/brain/${group}${subjID}/ses-second/
    # fi

    # DIR_third=${home}/SOURCEDATA/brain/${group}${subjID}/third/
    # if [ -d "$DIR_third" ]; then
    #   mv ${home}/SOURCEDATA/brain/${group}${subjID}/third/ ${home}/SOURCEDATA/brain/${group}${subjID}/ses-third/
    # fi

#     DIR_second=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/fmap/
#     if [ -d "$DIR_second" ]; then

#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*hedonicreactivity_magnitude1.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-hedonicreactivity_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*hedonicreactivity_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-hedonicreactivity_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*hedonicreactivity_phasediff.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-hedonicreactivity_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*hedonicreactivity_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-hedonicreactivity_phasediff.nii.gz

#     fi


#     DIR_third=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/fmap/
#     if [ -d "$DIR_third" ]; then
     

#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*hedonicreactivity_magnitude1.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-hedonicreactivity_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*hedonicreactivity_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-hedonicreactivity_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*hedonicreactivity_phasediff.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-hedonicreactivity_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*hedonicreactivity_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-hedonicreactivity_phasediff.nii.gz

#     fi


# #instrumentallearning


#     DIR_second=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/fmap/
#     if [ -d "$DIR_second" ]; then

#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*instrumentallearning_magnitude1.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-instrumentallearning_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*instrumentallearning_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-instrumentallearning_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*instrumentallearning_phasediff.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-instrumentallearning_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*instrumentallearning_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-instrumentallearning_phasediff.nii.gz

#     fi


#     DIR_third=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/fmap/
#     if [ -d "$DIR_third" ]; then
     

#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*instrumentallearning_magnitude1.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-instrumentallearning_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*instrumentallearning_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-instrumentallearning_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*instrumentallearning_phasediff.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-instrumentallearning_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*instrumentallearning_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-instrumentallearning_phasediff.nii.gz

#     fi
#   #pavlovianlearning

#     DIR_second=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/fmap/
#     if [ -d "$DIR_second" ]; then

#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*pavlovianlearning_magnitude1.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-pavlovianlearning_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*pavlovianlearning_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-pavlovianlearning_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*pavlovianlearning_phasediff.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-pavlovianlearning_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*pavlovianlearning_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-pavlovianlearning_phasediff.nii.gz

#     fi


#     DIR_third=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/fmap/
#     if [ -d "$DIR_third" ]; then
     

#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*pavlovianlearning_magnitude1.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-pavlovianlearning_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*pavlovianlearning_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-pavlovianlearning_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*pavlovianlearning_phasediff.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-pavlovianlearning_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*pavlovianlearning_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-pavlovianlearning_phasediff.nii.gz

#     fi

# #PIT
#       DIR_second=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-second/fmap/
#     if [ -d "$DIR_second" ]; then

#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*PIT_magnitude1.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-PIT_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*PIT_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-PIT_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*PIT_phasediff.json ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-PIT_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-second/fmap/*PIT_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-second/fmap/sub-${group}${subjID}_ses-second_task-PIT_phasediff.nii.gz

#     fi


#     DIR_third=${home}/DATA/STUDY/SOURCEDATA/sub-${group}${subjID}/ses-third/fmap/
#     if [ -d "$DIR_third" ]; then
     

#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*PIT_magnitude1.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-PIT_magnitude.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*PIT_magnitude1.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-PIT_magnitude.nii.gz
      
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*PIT_phasediff.json ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-PIT_phasediff.json
#       mv ${home}/sub-${group}${subjID}/ses-third/fmap/*PIT_phasediff.nii.gz ${home}/sub-${group}${subjID}/ses-third/fmap/sub-${group}${subjID}_ses-third_task-PIT_phasediff.nii.gz

#     fi