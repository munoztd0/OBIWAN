#!/bin/bash

# deprecated: before use of different fieldmaps in fMRI protocol
# updates IntendedFor field in json


sessionID="third"

for subID in obese204
do

  # path to original fieldmap directory
  fmapDir=/home/cisa/Documents/BIDS/BIDS/sub-${subID}/ses-${sessionID}/fmap/
  # path to output fieldmap directory
  fmapOutDir=/home/cisa/Documents/BIDS/BIDS/sub-${subID}/ses-${sessionID}/fmap_temp/
  # make the fieldmap output Directory
  mkdir -p ${fmapOutDir}

  # loop through original image label
  for imageTypeLabel in acq-task acq-task_phasediff
  do

    # loop through run numbers
    for runID in {1..15}
    do

      echo ____________________________________________________
      echo Run: ${runID}

      # zero-pad the run number
      while [ ${#runID} -ne 2 ];
      do
        runID="0"$runID
      done

      # path to original fieldmaps
      jsonFile=${fmapDir}sub-${subID}_ses-${sessionID}_run-${runID}_${imageTypeLabel}.json
      niftiFile=${fmapDir}`basename ${jsonFile} .json`.nii.gz

      # find out if file exists
      if [ -f "$jsonFile" ]
      then
        echo "Started working on file `basename $jsonFile .json`"


      # find correct run number in json
      seriesNumber=$(jq -r '.SeriesNumber' ${jsonFile})

      # attribute task corresponding to run number
#      if [ $seriesNumber -eq 2 -o $seriesNumber -eq 3 ]; then
      if [ $seriesNumber -eq 5 -o $seriesNumber -eq 6 ]; then
        taskID="pavlovianlearning"
#      elif [ $seriesNumber -eq 5 -o $seriesNumber -eq 6 ]; then
      elif [ $seriesNumber -eq 8 -o $seriesNumber -eq 9 ]; then
        taskID="instrumentallearning"
#      elif [ $seriesNumber -eq 8 -o $seriesNumber -eq 9 ]; then
      elif [ $seriesNumber -eq 11 -o $seriesNumber -eq 12 ]; then
        taskID="PIT"
#      elif [ $seriesNumber -eq 11 -o $seriesNumber -eq 12 ]; then
      elif [ $seriesNumber -eq 14 -o $seriesNumber -eq 15 ]; then
        taskID="hedonicreactivity"
      fi

      # zero-pad the series number
      while [ ${#seriesNumber} -ne 2 ];
      do
        seriesNumber="0"$seriesNumber
      done

      echo "Series number: $seriesNumber"

      # find echo number in json
      echoNumber=$(jq -r '.EchoNumber' ${jsonFile})
      echo "Echo number: $echoNumber"

      # apply type of image corresponding to echo number
      if [ $echoNumber -eq 1 ]; then
        imageType="magnitude1"
      elif [ $echoNumber -eq 2 ]; then
        imageType="phasediff"
      fi

      # create new file name
      fileName=sub-${subID}_ses-${sessionID}_acq-task-${taskID}_${imageType}


      echo "Task: ${taskID}"
      echo "Image type: ${imageType}"
      echo ${fileName}

      # rename json file
      cp -v ${jsonFile} ${fmapOutDir}${fileName}.json
      # rename nifti file
      cp -v ${niftiFile} ${fmapOutDir}${fileName}.nii.gz

      # change IntendedFor field in json file
      export IntendedFor="ses-${sessionID}/func/ses-${sessionID}_task-${taskID}_bold.nii.gz"
      jq '.IntendedFor=env.IntendedFor' ${fmapOutDir}${fileName}.json > ${fmapOutDir}${fileName}_temp.json && mv ${fmapOutDir}${fileName}_temp.json ${fmapOutDir}${fileName}.json

      else

        echo "File `basename $jsonFile .json` doesn't exist."

      fi

    done

  done


  # make sure all processes are finished before proceding
  wait

  # change name of input fmap directory
  mv -v ${fmapDir} /home/cisa/Documents/BIDS/BIDS/sub-${subID}/ses-${sessionID}/fmap_old/
  # change name of output fmap directory
  mv -v ${fmapOutDir} ${fmapDir}

  wait

#  rm -rf /home/OBIWAN/DATA/STUDY/RAW/BIDS/sub-${subID}/ses-${sessionID}/fmap_old/

done
