#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:07:51 2019

@author: logancross
modified by eva on May 13 2019
"""

import sys
# this is just for my own machine
sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/") 

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils_pav


ana_name  = 'MVPA-02'
homedir = '/Users/evapool/mountpoint/'

#add utils to path
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')

#PERMUTATION TESTING PROCEDURE PERFORMED AS DESCRIBED AS IN STELZER
#https://www.sciencedirect.com/science/article/pii/S1053811912009810?via%3Dihub#bb0035
#FIRST LEVEL PERMUTATIONS FOR A SINGLE SUBJECT PERFORMED HERE

###SCRIPT ARGUMENTS

subj = '01'

runs2use = 2

#which ds to use and which mask to use
glm_ds_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name   = homedir+'DATA/brain/MODELS/SPM/GLM-MF-09a/sub-'+subj+'/output/mask.nii'


#customize how trials should be labeled as classes for classifier
#timing files 1
class_dict = {
		'csm' : 0,
		'cs_deval' : 1,
		'cs_val' : 1,
	}

#timing files 2
class_dict2 = {
		'csm' : 0,
		'cs_deval_L' : 1,
         'cs_deval_R' : 1,
		'cs_val_L' : 1,
         'cs_val_R' : 1,
	}

#number of permutations to run 
num_perms = 3 #100

###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name)

#use a balancer to make a balanced dataset of even amounts of samples in each class
balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')

#SVM classifier
clf = LinearCSVMC()

#PERMUTATION TESTS FOR SINGLE SUBJECT LEVEL
#CLASS LABELS ARE SHUFFLED 100 TIMES TO CREATE A NONPARAMETRIC NULL DISTRIBUTION
vector_file= homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-'
perm_file = vector_file+'_nulldist.hdf5'
perm_sl = slClassPermTest_1Ss(fds, perm_count = num_perms, radius = 3, 
                              clf = clf, part = balancer, status_print = 1, h5 = 1, 
                              h5out = perm_file)
