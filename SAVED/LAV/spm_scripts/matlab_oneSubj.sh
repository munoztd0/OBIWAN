#!/bin/bash

echo "Bash version ${BASH_VERSION}..."

#PBS -q default
#PBS -l nodes=1
#PBS -l walltime=4:00:00
#PBS -m ae
#PBS -M evapool@caltech.edu

MATLAB=/usr/local/MATLAB/R2017a/bin/matlab

PBS_O_WORKDIR=$2

echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

NPROCS=`wc -l < $PBS_NODEFILE`

echo This job has allocated $NPROCS cpus

matlab_script=$3
sbj=$1


#PBS -N cluster_analysis_classic_preproc
$MATLAB -nojvm -nodisplay -nosplash -r "${matlab_script}({'$sbj'}); exit"
# $MATLAB -nodisplay -nosplash -r "${matlab_script}({'$sbj'}); exit"
