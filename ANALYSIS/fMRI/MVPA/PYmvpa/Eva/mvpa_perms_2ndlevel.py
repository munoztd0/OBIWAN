#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:28:57 2019

@author: logancross
"""

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils_pav
import sys

your_path = '/Users/logancross/Documents/EvaPavlovian/'

#add utils to path
sys.path.insert(0, your_path+'mvpa')

#svm (classification) or rsa result
analysis_prefix = 'svm'

subjs_in_group = ['01','07']

#number of permutations done at the first level
num_perms=100

###################################################
#load a sample subject to get the voxel information
subj_temp = subjs_in_group[0]
sample_standard_img = your_path+'mvpa/analyses/sub-'+subj_temp+'/'+analysis_prefix+'_cs+_cs-_standard'
fds_standard = fmri_dataset(samples=sample_standard_img, targets=0, chunks=0, mask=sample_standard_img)

#number of voxels in standard template
num_voxs = fds_standard.shape[1]
###################################################

#PERMUTATION TESTS ENTERED AT THE SECOND LEVEL
#PROCEDURE PERFORMED AS DESCRIBED HERE https://www.sciencedirect.com/science/article/pii/S1053811912009810?via%3Dihub#bb0035
#MORE INFORMATION ON PYMVPA PROCEDURE HERE http://www.pymvpa.org/generated/mvpa2.algorithms.group_clusterthr.GroupClusterThreshold.html#r3
#slightly untested - needs to be tested with full dataset of subjects

#loop through the subjects, and concatenate to map a big matrix of accuracies, permutation accuracies, and a different chunk label for every subject 
acc_map_all_subjs = np.zeros([len(subjs_in_group),num_voxs])
perms_all_subjs = np.zeros([num_perms*len(subjs_in_group),num_voxs])
chunks = np.zeros(num_perms*len(subjs_in_group))
subj_count = -1
for subj in subjs_in_group:
    subj_count+=1
    vector_file = '/Users/logancross/Documents/EvaPavlovian/mvpa/permutation_tests/sub-'+subj+'/sample_svm_cs+_cs-'
    #vector_file = '/Users/logancross/Documents/EvaPavlovian/mvpa/analyses/sub-'+subj+'/'+analysis_prefix+'_cs+_cs-'
    temp_results = h5load(vector_file)
    acc_map_all_subjs[subj_count,:] = temp_results
    perm_file = vector_file+'_nulldist.hdf5'
    temp_perms = h5load(perm_file).samples
    #reshape and transpose to get num perms x num voxels
    temp_perms_reshape = temp_perms.reshape(num_voxs, num_perms).T
    perms_all_subjs[(subj_count*100):((1+subj_count)*100),:] = temp_perms_reshape
    chunks[(subj_count*100):((1+subj_count)*100)] = subj_count*np.ones(num_perms)

#create a pymvpa dataset that concatenates the accuracy maps for every subject    
mean_map = fds_standard.copy(deep=False, sa=[], fa=['voxel_indices'], a=['voxel_dim','mapper','voxel_eldim'])
mean_map.samples = acc_map_all_subjs
#create a pymvpa dataset that concatenates the permutation maps for every subject  
perms = fds_standard.copy(deep=False, sa=[], fa=['voxel_indices'], a=['voxel_dim','mapper','voxel_eldim'])
perms.samples = perms_all_subjs
perms.sa.set_length_check(len(chunks))
#chunks tell pymvpa which samples belong to which subject
perms.sa['chunks'] = chunks.astype(int)

fwe_rate = .05
n_bootstrap = 10000
save_file = your_path+'mvpa/analyses/group/'+analysis_prefix+'_cs+_cs-_slClassPerm.hdf5'
group_result = Perm_GroupClusterThreshold(mean_map, perms, NN = 1, feature_thresh_prob = .005, n_bootstrap = n_bootstrap, fwe_rate = fwe_rate, h5 = 1, h5out = save_file)