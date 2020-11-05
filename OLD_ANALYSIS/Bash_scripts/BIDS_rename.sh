 #!/bin/bash

# still need to change IntendedFor field in fieldmap jsons

for sessionID in first second third
do

  for subID in obese225
  do

    sessionDir=/home/cisa/Documents/temp/test/BIDSvalidation/BIDS/sub-${subID}/ses-${sessionID}/

    if [ "$sessionID" == "first" ]; then

      # path to original anat directory
      inDir=${sessionDir}anat/
      # path to output anat directory
      outDir=${sessionDir}anat_temp/
      # make the anat output directory
      mkdir -p ${outDir}

      # loop through modalities
      for modID in T1 T2
      do

        # path to original anatomicals
        jsonFile=${inDir}sub-${subID}_ses-${sessionID}_run-01_${modID}.json
        niftiFile=${inDir}`basename ${jsonFile} .json`.nii.gz

        # write new file name
        fileName=sub-${subID}_ses-${sessionID}_${modID}w

        # rename json file
        cp -v ${jsonFile} ${outDir}${fileName}.json
        # rename nifti file
        cp -v ${niftiFile} ${outDir}${fileName}.nii.gz

      done

      # make sure all processes are finished before proceeding
      wait

      # change name of input anat directory
      mv -v ${inDir} ${sessionDir}anat_old/
      # change name of output anat directory
      mv -v ${outDir} ${inDir}

    elif [ "$sessionID" == "second" ] || [ "$sessionID" == "third" ]; then

      for dirID in func fmap
      do

        # path to original directory
        inDir=${sessionDir}${dirID}/
        # path to output directory
        outDir=${sessionDir}${dirID}_temp/
        # make the output directory
        mkdir -p ${outDir}

        for taskID in pavlovianlearning instrumentallearning PIT hedonicreactivity
        do

          if [ "$dirID" == "func" ]; then

            # path to original functionals
            jsonFile=${inDir}sub-${subID}_ses-${sessionID}_task-${taskID}_run-01_bold.json
            niftiFile=${inDir}`basename ${jsonFile} .json`.nii.gz

            # write new file name
            fileName=sub-${subID}_ses-${sessionID}_task-${taskID}_bold

            # rename json file
            cp -v ${jsonFile} ${outDir}${fileName}.json
            # rename nifti file
            cp -v ${niftiFile} ${outDir}${fileName}.nii.gz


          elif [ "$dirID" == "fmap" ]; then

            # loop through fieldmap images
            for fmapID in magnitude1 phasediff
            do

              # path to original fieldmaps
              jsonFile=${inDir}sub-${subID}_ses-${sessionID}_acq-task-${taskID}_${fmapID}.json
              niftiFile=${inDir}`basename ${jsonFile} .json`.nii.gz

              # write new file name
              fileName=sub-${subID}_ses-${sessionID}_acq-task${taskID}_${fmapID}

              # rename json file
              cp -v ${jsonFile} ${outDir}${fileName}.json
              # rename nifti file
              cp -v ${niftiFile} ${outDir}${fileName}.nii.gz


            done

          fi


          # make sure all processes are finished before proceeding
          wait

        done

        # change name of input directory
        mv -v ${inDir} ${sessionDir}${dirID}_old/
        # change name of output directory
        mv -v ${outDir} ${inDir}

      done

    fi

  done

done
