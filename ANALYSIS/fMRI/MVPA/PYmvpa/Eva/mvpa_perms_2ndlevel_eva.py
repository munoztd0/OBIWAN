#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:28:57 2019

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

#svm (classification) or rsa result
analysis_prefix = 'svm'

subjs_in_group = ['01','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30']

subjs_in_group = ['01','03','07']

#number of permutations done at the first level
num_perms=3

###################################################
#load a sample subject to get the voxel information

# we dont have a standard so we use the subject with the larger number of voxels to initalize the matrix
n_voxels = np.zeros([1,len(subjs_in_group)])
subj_count = -1
for subj in subjs_in_group:
    subj_count+=1
    vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/'+analysis_prefix+'_cs+_cs-'
    temp_results = h5load(vector_file)
    n_voxels[0,subj_count] = temp_results.shape[1] # we need to get the actual size of the matrix

idx = np.argmax(n_voxels)

subj_temp = subjs_in_group[idx]
sample_standard_img = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj_temp+'/mvpa/'+analysis_prefix+'_cs+_cs-.nii.gz'
fds_standard = fmri_dataset(samples=sample_standard_img, targets=0, chunks=0, mask=sample_standard_img)

#number of voxels in standard template
num_voxs = fds_standard.shape[1]
###################################################

#PERMUTATION TESTS ENTERED AT THE SECOND LEVEL
#PROCEDURE PERFORMED AS DESCRIBED HERE https://www.sciencedirect.com/science/article/pii/S1053811912009810?via%3Dihub#bb0035
#MORE INFORMATION ON PYMVPA PROCEDURE HERE http://www.pymvpa.org/generated/mvpa2.algorithms.group_clusterthr.GroupClusterThreshold.html#r3
#slightly untested - needs to be tested with full dataset of subjects

#loop through the subjects, and concatenate to map a big matrix of accuracies, permutation accuracies, and a different chunk label for every subject 
acc_map_all_subjs = np.empty([len(subjs_in_group),num_voxs])
acc_map_all_subjs[:,:] = np.nan
perms_all_subjs = np.empty([num_perms*len(subjs_in_group),num_voxs])
perms_all_subjs[:,:] = np.nan # maybe better to initialize with zeros
chunks = np.zeros(num_perms*len(subjs_in_group))
chunks [:] = np.nan
subj_count = -1
for subj in subjs_in_group:
    subj_count+=1
    vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/'+analysis_prefix+'_cs+_cs-'
    temp_results = h5load(vector_file)
    temp_length = temp_results.shape[1] # we need to get the actual size of the matrix
    acc_map_all_subjs[subj_count,0:temp_length] = temp_results
    perm_file = vector_file+'_nulldist.hdf5'
    temp_perms = h5load(perm_file).samples
    
    #reshape and transpose to get num perms x num voxels
    temp_perms_reshape = temp_perms.reshape(temp_length, num_perms).T
    perms_all_subjs[(subj_count*num_perms):((1+subj_count)*num_perms),0:temp_length] = temp_perms_reshape
    chunks[(subj_count*num_perms):((1+subj_count)*num_perms)] = subj_count*np.ones(num_perms)

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
save_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/group/'+analysis_prefix+'_cs+_cs-_slClassPerm.hdf5'

group_result = Perm_GroupClusterThreshold(mean_map, perms, NN = 1, feature_thresh_prob = .005, n_bootstrap = n_bootstrap, fwe_rate = fwe_rate, h5 = 1, h5out = save_file)

# save thresholded mask
nimg = map2nifti (fds_standard, group_result.fa.clusters_fwe_thresh)
nii_file = save_file+'thresholded.nii.gz'
nimg.to_filename(nii_file)