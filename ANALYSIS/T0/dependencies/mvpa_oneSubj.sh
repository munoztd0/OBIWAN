#!/bin/bash

echo "Bash version ${BASH_VERSION}..."

PYTHON="/usr/bin/python2.7"

PBS_O_WORKDIR=$4

echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

NPROCS=`wc -l < $PBS_NODEFILE`

echo This job has allocated $NPROCS cpus

mvpa_script=$5
sbj=$1
tsk=$2
mdl=$3

#PBS -N cluster_analysis_classic_preproc
$PYTHON  ${mvpa_script} $sbj $tsk $mdl
