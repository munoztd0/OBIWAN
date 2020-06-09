#!/bin/bash


# create_sphere script
makespheres=/home/eva/PAVMOD/ANALYSIS/fsl_scripts/ROI/create_sphere.sh
# template space we are interested in
targetImage=/home/eva/PAVMOD/DATA/brain/CANONICALS/CIT168_T1w_MNI_lowres.nii.gz
# output directory
outputROI=/home/eva/PAVMOD/DATA/brain/ROI/GLM-MF-09a/


# FROM CSp VS CSm contrast

# name of the ROI
declare -a names=( ${outputROI}'VSleft' ${outputROI}'VSright' ${outputROI}'LOCleft' ${outputROI}'LOCright' ${outputROI}'Hypleft' ${outputROI}'Hypright')
# x coordinates in voxels
declare -a xs=('31' '42' '19' '52' '44' '26')
# y coordinates in voxels
declare -a ys=('58' '56' '18' '19' '35' '36')
# z coordinates in voxels
declare -a zs=('31' '28' '28' '27' '28' '30')

for i in {0..5}
  do
    echo  ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}
    qsub -o ~/ClusterOutput -j oe -l walltime=72:00:00,pmem=9GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N createROIs_${names[$i]} -F "${targetImage} ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}" ${makespheres}
  done


# FROM ANTp VS ANTm contrast
declare -a names=( ${outputROI}'SMC' ${outputROI}'INSleft' ${outputROI}'INSright')
# x coordinates in voxels
declare -a xs=('37' '48' '20')
# y coordinates in voxels
declare -a ys=('52' '61' '60')
# z coordinates in voxels
declare -a zs=('52' '30' '30')

for i in {0..2}
  do
    echo  ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}
    qsub -o ~/ClusterOutput -j oe -l walltime=72:00:00,pmem=9GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N createROIs_${names[$i]} -F "${targetImage} ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}" ${makespheres}
  done


# FROM reward VS no reward contrast
declare -a names=( ${outputROI}'VS' ${outputROI}'vmPFC' ${outputROI}'VTA')
# x coordinates in voxels
declare -a xs=('37' '38' '37')
# y coordinates in voxels
declare -a ys=('53' '69' '43')
# z coordinates in voxels
declare -a zs=('26' '24' '26')

for i in {0..2}
  do
    echo  ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}
    qsub -o ~/ClusterOutput -j oe -l walltime=72:00:00,pmem=9GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N createROIs_${names[$i]} -F "${targetImage} ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}" ${makespheres}
  done


# FROM region we expect activation but there is none

declare -a names=( ${outputROI}'AMYleft' ${outputROI}'AMYright' ${outputROI}'OFCleft' ${outputROI}'OFCright')
# x coordinates in voxels
declare -a xs=('27' '45' '27' '46' )
# y coordinates in voxels
declare -a ys=('49' '49' '60' '60')
# z coordinates in voxels
declare -a zs=('20' '20' '20' '21')

for i in {0..3}
  do
    echo  ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}
    qsub -o ~/ClusterOutput -j oe -l walltime=72:00:00,pmem=9GB -M eva.pool@unige.ch -m e -l nodes=1 -q queue1 -N createROIs_${names[$i]} -F "${targetImage} ${names[$i]} ${xs[$i]} ${ys[$i]} ${zs[$i]}" ${makespheres}
  done
