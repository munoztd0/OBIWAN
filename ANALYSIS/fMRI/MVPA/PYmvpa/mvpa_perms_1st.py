#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:07:51 2019

@author: logancross
modified by david on May 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

from mvpa2.suite import *
import matplotlib.pyplot as plt
from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
from mvpa2.datasets.miscfx import remove_invariant_features
import sys
import os
# import utilities
homedir = os.path.expanduser('~/REWOD/')
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils
import time

###radius 2## 6 min per perm ~10h for 100


#PERMUTATION TESTING PROCEDURE PERFORMED AS DESCRIBED AS IN STELZER
#https://www.sciencedirect.com/science/article/pii/S1053811912009810?via%3Dihub#bb0035
#FIRST LEVEL PERMUTATIONS FOR A SINGLE SUBJECT PERFORMED HERE

# ---------------------------- Script arguments
subj = str(sys.argv[1])
#subj = '01'

task = str(sys.argv[2])
#task = 'hedonic'

model = str(sys.argv[3])
#model = 'MVPA-04'
runs2use = 1 ##??

#number of permutations to run
num_perms = 100

print 'subject id: ', subj
print 'number of perms: ', num_perms

runs2use = 1 ##!

#which ds to use and which mask to use

glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
#mask_name = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/anat/sub-'+subj+'_ses-second_run-01_T1w_reoriented_brain_mask.nii'
mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'


#customize how trials should be labeled as classes for classifier
#timing files 1
class_dict = {
        'empty' : 0,
        'chocolate' : 1,
        'neutral' : 1,  #watcha
    }


if model == 'MVPA-02':
    class_dict = {
        'empty' : 0,
        'chocolate' : 1,
    }


if model == 'MVPA-03' or model == 'MVPA-05':
    class_dict = {
        'neutral' : 0,
        'chocolate' : 1,
    }

if model == 'MVPA-05':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'

if model == 'MVPA-04':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'
    

# ---------------------------- define targets, classifier and searchlight

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task)

#basic preproc: detrending [likely not necessary since we work with HRF in GLM]
detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
detrended_fds = fds.get_mapped(detrender)

zscore(detrended_fds) ##
fds_z = detrended_fds ##

fds = remove_invariant_features(fds_z) ##

#use a balancer to make a balanced dataset of even amounts of samples in each class
balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')

#SVM classifier
clf = LinearCSVMC()

# ---------------------------- Run
#PERMUTATION TESTS FOR SINGLE SUBJECT LEVEL
#CLASS LABELS ARE SHUFFLED 100 TIMES TO CREATE A NONPARAMETRIC NULL DISTRIBUTION
vector_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa3/svm_smell_nosmell'

perm_file = vector_file+'_nulldist.hdf5'

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]

start_time = time.time()

print 'Starting training',time.time() 


perm_sl = slClassPermTest_1Ss(fds, perm_count = num_perms, radius = 2, ###
                            clf = clf, part = balancer, status_print = 0, h5 = 1,
                            h5out = perm_file)
# else: 
#     perm_sl = slClassPermTest_1Ss(fds, perm_count = num_perms, radius = 3,
#                               clf = clf, part = NFoldPartitioner(), status_print = 0, h5 = 1,
#                               h5out = perm_file)

print 'Finished training, it took',time.time() - start_time
print 'end'