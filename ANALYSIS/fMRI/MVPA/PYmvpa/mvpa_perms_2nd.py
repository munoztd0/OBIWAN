#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:28:57 2019

@author: logancross

last modified by david in 2020
"""
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import sys

import os
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils
import time

from sh import gunzip
from nilearn import image ## was missing this line!
#np.warnings.filterwarnings('ignore')

#svm (classification) or rsa result
analysis_prefix = 'svm'

# ---------------------------- Script arguments
#subj = str(sys.argv[1])
subj = '01'

#task = str(sys.argv[2])
task = 'hedonic'

#model = str(sys.argv[3])
model = 'MVPA-04'
runs2use = 1 ##??


#number of permutations done at the first level
num_perms=100 #00

###################################################
#load a sample subject to get the voxel information
subjs_in_group = ['01', '02', '03', '04', '05', '06', '07', '09', '10', '11','12', '13', '14', '15', '16', '17', '18', '20', '21', '22', '23', '24', '25', '26'] # 


# we dont have a standard so we use the subject with the larger number of voxels to initalize the matrix
# n_voxels = np.zeros([1,len(subjs_in_group)])
# subj_count = -1
# for subj in subjs_in_group:
#     subj_count+=1
#     vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/'+analysis_prefix+'_cs+_cs-'
#     temp_results = h5load(vector_file)
#     n_voxels[0,subj_count] = temp_results.shape[1] # we need to get the actual size of the matrix

# idx = np.argmax(n_voxels)

# subj_temp = subjs_in_group[idx]
# sample_standard_img = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj_temp+'/mvpa/'+analysis_prefix+'_cs+_cs-.nii.gz'
# fds_standard = fmri_dataset(samples=sample_standard_img, targets=0, chunks=0, mask=sample_standard_img)

# #number of voxels in standard template
# num_voxs = fds_standard.shape[1]

subj_temp = subjs_in_group[0]
sample_standard_img = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/'+analysis_prefix+'_smell_nosmell.nii.gz'
fds_standard = fmri_dataset(samples=sample_standard_img, targets=0, chunks=0, mask=sample_standard_img)

#number of voxels in standard template
num_voxs = fds_standard.shape[1]

start_time = time.time()

print 'Starting'
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
#perms_all_subjs = np.zeros([num_perms*len(subjs_in_group),num_voxs])
chunks = np.zeros(num_perms*len(subjs_in_group))
chunks [:] = np.nan
subj_count = -1




# acc_map_all_subjs = np.zeros([len(subjs_in_group),num_voxs])
# chunks = np.zeros(num_perms*len(subjs_in_group))
# subj_count = -1

for subj in subjs_in_group:
    subj_count+=1
    vector_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/'+analysis_prefix+'_smell_nosmell'
    temp_results = h5load(vector_file)
    temp_length = temp_results.shape[1] # we need to get the actual size of the matrix
    acc_map_all_subjs[subj_count,0:temp_length] = temp_results
    
    #temp_results = h5load(vector_file)
    #acc_map_all_subjs[subj_count,:] = temp_results
    perm_file = vector_file+'_nulldist.hdf5'
    temp_perms = h5load(perm_file).samples
    #reshape and transpose to get num perms x num voxels
    temp_perms_reshape = temp_perms.reshape(temp_length, num_perms).T
    perms_all_subjs[(subj_count*num_perms):((1+subj_count)*num_perms),0:temp_length] = temp_perms_reshape
    chunks[(subj_count*num_perms):((1+subj_count)*num_perms)] = subj_count*np.ones(num_perms)
    #temp_perms_reshape = temp_perms.reshape(temp_length, num_perms).T
    #perms_all_subjs[(subj_count*num_perms):((1+subj_count)*num_perms),0:] = temp_perms_reshape
    #chunks[(subj_count*num_perms):((1+subj_count)*num_perms)] = subj_count*np.ones(num_perms)

#create a pymvpa dataset that concatenates the accuracy maps for every subject    
mean_map = fds_standard.copy(deep=False, sa=[], fa=['voxel_indices'], a=['voxel_dim','mapper','voxel_eldim'])
mean_map.samples = acc_map_all_subjs
#create a pymvpa dataset that concatenates the permutation maps for every subject  
perms = fds_standard.copy(deep=False, sa=[], fa=['voxel_indices'], a=['voxel_dim','mapper','voxel_eldim'])
perms.samples = perms_all_subjs
perms.sa.set_length_check(len(chunks))
#chunks tell pymvpa which samples belong to which subject
perms.sa['chunks'] = chunks.astype(int)

fwe_rate = 0.05  #fwe at 0.1
n_bootstrap = 10000 # 100000#
feature_thresh_prob = 0.0001 # 0.001
NN = 1
#feature_thresh_prob 
save_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/'+analysis_prefix+'_smell_nosmell_Perm.hdf5'
h5out = save_file
#group_result = Perm_GroupClusterThreshold(mean_map, perms, NN = 1, feature_thresh_prob = feat_prob, n_bootstrap = n_bootstrap, fwe_rate = fwe_rate, h5 = 1, h5out = save_file)
#group_result = Perm_GroupClusterThreshold(mean_map, perms, NN = 3, feature_thresh_prob = feat_prob, n_bootstrap = n_bootstrap, fwe_rate = fwe_rate, h5 = 1, h5out = save_file)


if NN == 1: 
    clthr = GroupClusterThreshold(feature_thresh_prob=feature_thresh_prob,n_bootstrap=n_bootstrap,fwe_rate=fwe_rate)
elif NN == 3:
    clthr = gct_pymvpaw.GroupClusterThreshold_NN3(feature_thresh_prob=feature_thresh_prob,n_bootstrap=n_bootstrap,fwe_rate=fwe_rate, multicomp_correction = None)
    
print('Beginning to bootstrap... dont hold your breath here (has taken close to an hour for an example I did with 1600 samples in perms)')
clthr.train(perms)
print('Null distribution and cluster measurements complete, applying to group result map')
res = clthr(mean_map)
print('Correction complete... see res.a for stats table etc., res.fa.clusters_fwe_thresh for a mask of clusters that survived - see doc')

h5save(h5out, res, compression=9)


group_result = res
# # save thresholded mask
#nimg = map2nifti (fds_standard, group_result.fa.clusters_fwe_thresh)
#nii_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/'+analysis_prefix+'_smell_nosmell_Perm_thresholdedFWE.nii.gz'
#nimg.to_filename(nii_file)

nimg = map2nifti (fds_standard, group_result.fa.featurewise_thresh)
nii_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/'+analysis_prefix+'_smell_nosmell_Perm_featurewise_thresh.nii.gz'
nimg.to_filename(nii_file)

nimg = map2nifti (fds_standard, group_result.fa.clusters_featurewise_thresh)
nii_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/'+analysis_prefix+'_smell_nosmell_Perm_clusters_featurewise_thresh.nii.gz'
nimg.to_filename(nii_file)

print 'Finished, it took',time.time() - start_time
print 'end'