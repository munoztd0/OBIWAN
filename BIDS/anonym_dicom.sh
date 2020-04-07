#script to unzip dicom.7z files, but first you need to instal 7-zip !
# by David Munoz - last modified in march 2020 - enjoy

home=$(eval echo ~$user)
codeDir="${home}/REWOD/CODE/BIDS"
matlab_script="dicom_anonym"
matlabSubmit="${home}/REWOD/CODE/BIDS/import_dicom/matlab_run.sh"


#SAVED is where I have the dicom files uploaded
for subj in 01 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
  do
    #1)unzip files
    7za e ${home}/REWOD/SOURCEDATA/brain/${subj}/dcm/*.7z -o${home}/REWOD/SOURCE/${subj}/dcm/

    #2) run run_anonym
    #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=0:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N anonym_sub-${subj} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

    #3) then when the naonym is finished ONLY you can uncomment the following and comment out 1) & 2)
    #mkdir ${home}/REWOD/SOURCE/${subj}/dcm_anonym
    #cd ${home}/REWOD/SOURCE/${subj}/dcm/

    #for f in *_an
      #do newname=$( echo $f | sed 's/.\{3\}$//' )  #chops off the *_an part
        #cp $f ${home}/REWOD/SOURCE/${subj}/dcm_anonym/$newname
    #done

    #4) REMOVES THE NON ANONYMIZED FOLDER SO BE CAREFULE TO HAVE A BACKUP IN CASE
    #rm -r ${home}/REWOD/SOURCE/${subj}/dcm

    echo "done for sub-${subj}"

done
