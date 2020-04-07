#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu May  2 17:20:13 2019

@author: logancross
"""

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures import rsa
from mvpa2.measures.searchlight import sphere_searchlight
from scipy.spatial.distance import squareform
import mvpa_utils_pav

your_path = '/Users/logancross/Documents/EvaPavlovian/'

#add utils to path
sys.path.insert(0, your_path+'mvpa')

###SCRIPT ARGUMENTS

subj = '01'

runs2use = 2

square_dsm_bool = True

plot_dsm = False #square_dsm_bool must also be true

#which ds to use and which mask to use
glm_ds_file = '/Users/logancross/Documents/EvaPavlovian/analysis/sub-'+subj+'/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name = '/Users/logancross/Documents/EvaPavlovian/data/sub-'+subj+'/func/func_mask.nii.gz'

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

###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict)

#control dsm for run
num_trials = fds.shape[0]
ds_run = dataset_wizard(fds.chunks, targets=np.zeros(num_trials))

dsm = PDist(pairwise_metric='matching', square=square_dsm_bool)
dsm_run = dsm(ds_run)

if plot_dsm and square_dsm_bool:
    mvpa_utils_pav.plot_mtx(dsm_run, np.arange(num_trials), 'ROI pattern correlation distances by run')

#create dsm for CS+ and CS-
ds_cs = dataset_wizard(fds.targets, targets=np.zeros(num_trials))

dsm = PDist(pairwise_metric='matching', square=square_dsm_bool)
dsm_cs = dsm(ds_cs)

if plot_dsm and square_dsm_bool:
    mvpa_utils_pav.plot_mtx(dsm_cs, np.arange(num_trials), 'ROI pattern correlation distances CS+ vs CS-')
    
#PERMUTATION TESTS FOR SINGLE SUBJECT LEVEL
#CLASS LABELS ARE SHUFFLED 100 TIMES TO CREATE A NONPARAMETRIC NULL DISTRIBUTION
num_perms = 100

num_voxs = fds.shape[1]
nulls = np.zeros([num_voxs, num_perms])
for i in range(num_perms):
    print 'Permutation ',i
    nulls[:,i] = slRSA_m_1Ss(fds, DMshuffle(dsm_cs), partial_dsm = dsm_run, cmetric = 'spearman',status_print=0)
    
perm_file = '/Users/logancross/Documents/EvaPavlovian/mvpa/permutation_tests/sub-'+subj+'/rsa_cs+_cs-_nulldist.hdf5'
h5save(nulls,perm_file)