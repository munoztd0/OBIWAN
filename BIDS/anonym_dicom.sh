#script to unzip dicom.7z files, but first you need to instal 7-zip !
# by David Munoz - last modified in march 2020 - enjoy

home=$(eval echo ~$user)/OBIWAN

subjID=$1
group=$2


codeDir="${home}/CODE/BIDS"
matlab_script="dicom_anonym"
matlabSubmit="${home}/CODE/BIDS/import_dicom/matlab_run.sh"


#SAVED is where I have the dicom files uploaded

#1)uncompress files
7za e ${home}/SOURCEDATA/brain/${group}${subjID}/dcm/*.7z -o${home}/SOURCE/${group}${subjID}/dcm/

#2) run run_anonym
#qsub -o ${home}/ClusterOutput -j oe -l walltime=0:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N anonym_sub-${subjID} -F "${subjID} ${group} ${codeDir} ${matlab_script}" ${matlabSubmit}

#3) then when the naonym is finished ONLY you can uncomment the following and comment out 1) & 2)
#mkdir ${home}/SOURCE/${subjID}/dcm_anonym
#cd ${home}/SOURCE/${subjID}/dcm/

#for f in *_an
  #do newname=$( echo $f | sed 's/.\{3\}$//' )  #chops off the *_an part
    #cp $f ${home}/SOURCE/${subjID}/dcm_anonym/$newname
#done

#4) REMOVES THE NON ANONYMIZED FOLDER SO BE CAREFULE TO HAVE A BACKUP IN CASE
#rm -r ${home}/SOURCE/${subjID}/dcm

echo "done for sub-${subjID}"

