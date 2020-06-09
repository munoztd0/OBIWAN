# merge all anatomicals together into a single image file


outDir=/home/eva/PAVMOD/DATA/brain/CANONICALS/
mergedImage=${outDir}all_T1w.nii.gz
meanImage=${outDir}averaged_T1w.nii.gz

# add the standard space T1 as the initial image
#cp ${outDir}CIT168_T1w_MNI_lowres.nii.gz ${mergedImage}

# add the anatomincal of the first participant as the intial image
cp /home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-01/anat/sub-01_acq-ANTnorm_T1w.nii.gz ${mergedImage}
cpString=${mergedImage}

 for subj in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
 do
 			echo "appending: sub ${subj}"

 			cpString="${cpString} /home/eva/PAVMOD/DATA/brain/cleanBIDS/sub-${subj}/anat/sub-${subj}_acq-ANTnorm_T1w.nii.gz"

 done

echo ${cpString}
# put all the T1 in a single image to compute the mean across time
fslmerge -t ${mergedImage} ${cpString}
# Compute the mean of the 4d image containg all the anatomicals
fslmaths ${mergedImage} -Tmean ${meanImage}
