i#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu May  2 15:58:49 2019

@author: logancross

modified by eva on Feb 2020
"""

import sys
# this is just for my own machine
sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/") 




from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures import rsa
from mvpa2.measures.searchlight import sphere_searchlight
from scipy.spatial.distance import squareform

import os

os.chdir('/Users/evapool/mountpoint/PAVMOD/ANALYSIS/mvpa_scripts/PYmvpa')

import mvpa_utils_pav

ana_name  = 'MVPA-03'
homedir = '/Users/evapool/mountpoint/PAVMOD/'

#add utils to path
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')

###SCRIPT ARGUMENTS

subj = '01'

runs2use = 2

square_dsm_bool = True

plot_dsm = False #square_dsm_bool must also be true

plot_dsm = True #square_dsm_bool must also be true

#which ds to use and which mask to use
glm_ds_file = homedir+'DATA/brain/MODELS/RSA/MVPA-05/sub-'+subj+'/glm/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name = homedir+'DATA/brain/CANONICALS/averaged_T1w_mask.nii'

mask_name = '/Users/evapool/mountpoint/PAVMOD/DATA/brain/MODELS/RSA/MVPA-03/sub-01/glm/beta_everytrial_pav8/mask.nii'

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


class_dict03 = {
		'csm' : 0,
		'csp' : 1,
	}

###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils_pav.make_targets03(subj, glm_ds_file, mask_name, runs2use, class_dict03, homedir, ana_name)

#control dsm for run
num_trials = fds.shape[0]
ds_run = dataset_wizard(fds.chunks, targets=np.zeros(num_trials))

dsm_run = dsm(ds_run)
dsm = PDist(pairwise_metric='matching', square=square_dsm_bool)

if plot_dsm and square_dsm_bool:
    mvpa_utils_pav.plot_mtx(dsm_run, np.arange(num_trials), 'ROI pattern correlation distances by run')

#create dsm for CS+ and CS-
ds_cs = dataset_wizard(fds.targets, targets=np.zeros(num_trials))

dsm_cs = dsm(ds_cs)
dsm = PDist(pairwise_metric='matching', square=square_dsm_bool)

if plot_dsm and square_dsm_bool:
    mvpa_utils_pav.plot_mtx(dsm_cs, np.arange(num_trials), 'ROI pattern correlation distances CS+ vs CS-')

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]
    
#complete a searchlight to look for local voxel patterns encoding differences between CS+ and CS-
#a lot of dissimilarity is driven by differences across runs, partial this out

sl_fmri_res = slRSA_m_1Ss(fds, dsm_cs, partial_dsm = dsm_run, control_dsms = None, resid = False, radius=3, cmetric='spearman',status_print=1)

sl_fmri_res = slRSA_m_1Ss(fds, dsm_cs, control_dsms = None, resid = False, radius=3, cmetric='spearman',status_print=1)

#reverse map scores back into nifti format and save
scores_per_voxel = sl_fmri_res
vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/rsa_cs+_cs-'
h5save(vector_file,scores_per_voxel)
nimg = map2nifti(fds, scores_per_voxel)
nii_file = vector_file+'.nii.gz'
nimg.to_filename(nii_file)
