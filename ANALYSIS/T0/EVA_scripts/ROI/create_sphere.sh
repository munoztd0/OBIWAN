#!/bin/bash


# template space we are interested in
targetImage=$1 #/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/CIT168_T1w_MNI_lowres.nii.gz
# name of the ROI sphere
outputROI=$2 #/home/evapool/PAVMOD/ANALYSIS/fsl_script/ROI/GLM-03p/PREP2

# xyz coordinates in voxels
x=$3 #41
y=$4 #57
z=$5 #29

##################################
# create sphere
echo "target image: ${targetImage}"
echo "output point: ${outputROI}point"
echo "output sphere: ${outputROI}sphere"

fslmaths ${targetImage} -mul 0 -add 1 -roi ${x} 1 ${y} 1 ${z} 1 0 1 ${outputROI}point -odt float
fslmaths ${outputROI}point -kernel sphere 10 -fmean ${outputROI}ROI -odt float

###################################
# unzip for spm
echo "unzipping for spm $(date +"%T")"
gunzip -f ${outputROI}ROI.nii.gz
