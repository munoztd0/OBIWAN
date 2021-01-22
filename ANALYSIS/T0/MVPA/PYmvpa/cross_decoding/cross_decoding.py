#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 21 10:45:43 2019

@author: logancross
"""

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import sys

your_path = '/Users/logancross/Documents/EvaPavlovian/'

#add utils to path
sys.path.insert(0, your_path+'mvpa')
import mvpa_utils_pav
from mvpa_utils_pav import CrossDecodingFilter

###SCRIPT ARGUMENTS

subj = '01'

runs2use = 2

#which ds to use and which mask to use
glm_ds_file = your_path+'analysis/sub-'+subj+'/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name = your_path+'data/sub-'+subj+'/func/func_mask.nii.gz'

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

npart = NFoldPartitioner()
# modify partitioning behavior
cross_decode_chain = ChainNode([npart,
                      CrossDecodingFilter((('cs_deval'),('cs_val'),('csm')),
                               npart.get_space(),
                               'trial_type')
                     ],space='filtered_partitions')
                      
#SVM classifier
clf = LinearCSVMC()
#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
cv = CrossValidation(clf, cross_decode_chain, errorfx=lambda p, t: np.mean(p == t),enable_ca=['stats'])

#implement full brain searchlight with spheres with a radius of 3
svm_sl = sphere_searchlight(cv, radius=3, space='voxel_indices',
                             postproc=mean_sample())

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]
    
res_sl = svm_sl(fds)