#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 19 17:44:20 2019

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
                      
                      
print
print '================================================================='
print 'number of folds:', len(list(cross_decode_chain.generate(fds)))
print '-----------------------------------------------------------------'

fds_list = []
for p in cross_decode_chain.generate(fds):
    fds_list.append(p.sa.filtered_partitions)
    # convert to string to let it align in the output
    print 'PA', p.sa.filtered_partitions.astype('str')
    
#check which examples are in training set (1), testing set (2), and left out of the cv fold (0) in sa.filtered_partitions

#test that partitions where done correctly
part_num=0
for partition in fds_list:
    part_num+=1
    print 'Partition ',part_num
    
    left_out_inds = np.where(partition == 0)[0]
    train_inds = np.where(partition == 1)[0]
    test_inds = np.where(partition == 2)[0]
    
    #which runs are in train and test set
    train_chunks = fds.chunks[train_inds]
    train_run = np.unique(train_chunks)
    test_chunks = fds.chunks[test_inds]
    test_run = np.unique(test_chunks)
    
    if len(train_run) != 1 or len(test_run) != 1:
        print 'ERROR: More than one run in train/test set'
    elif train_run == test_run:
        print 'ERROR: Training and testing on the same run'
    else:
        print 'Training with run ',train_run[0]
        print 'Testing with run ',test_run[0]
        
    #are the CS+s in the training set different than ones in test set
    train_trial_type_all = fds.sa.trial_type[train_inds]
    train_trial_type = np.unique(train_trial_type_all)
    test_trial_type_all = fds.sa.trial_type[test_inds]
    test_trial_type = np.unique(test_trial_type_all)
    
    if len(train_trial_type) != 2 or len(test_run) != 1:
        print 'ERROR: Training or testing set trial types are off'
    elif test_trial_type == train_trial_type[0] or test_trial_type == train_trial_type[1]:
        print 'ERROR: Training or testing set trial types are off'
    else:
        print 'Training with ',train_trial_type
        print 'Testing with ',test_trial_type
        print '\n'
        
#Final test - Test that everything works correctly in a classification pipeline
#SVM classifier
clf = LinearCSVMC()
#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
cv = CrossValidation(clf, cross_decode_chain, errorfx=lambda p, t: np.mean(p == t),enable_ca=['stats'])

#for testing purposes just take first 1000 voxels in dataset
cv_results = cv(fds[:,:1000])

print cv.ca.stats.as_string(description=True)
    