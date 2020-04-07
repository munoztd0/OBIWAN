#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 21 10:45:43 2019

@author: logancross

modified by eva on June 2019
"""

import sys
# this is just for my own machine
sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/")


from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import sys
from sh import gunzip
# import utilities

homedir = '/home/eva/PAVMOD/'
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa/cross_decoding')
os.chdir(homedir+'ANALYSIS/mvpa_scripts/PYmvpa')
import mvpa_utils_pav
from mvpa_utils_pav import CrossDecodingFilter

# ---------------------------- Script arguments
ana_name  = 'MVPA-02'

subj = str(sys.argv[1])
print 'subject id: ', subj

runs2use = 2

#which ds to use and which mask to use
glm_ds_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name = homedir+'DATA/brain/CANONICALS/averaged_T1w_mask.nii'

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

# ---------------------------- define targets, classifier and searchlight

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name)

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

# ---------------------------- Run

#searchlight
# enable progress bar
# if __debug__:
#    debug.active += ["SLC"]

start_time = time.time()
print 'starting searchlight',time.time() - start_time

res_sl = svm_sl(fds)

sl_time = time.time() - start_time
print 'finished searchlight',sl_time

# ---------------------------- Save for perm
scores_per_voxel = res_sl.samples
vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/cross_cs+_cs-'
h5save(vector_file,scores_per_voxel)
nimg = map2nifti(fds, scores_per_voxel)
nii_file = vector_file+'.nii.gz'
nimg.to_filename(nii_file)

# ---------------------------- Save for quik ttest

# correct against chance level (0.5)
corrected_per_voxel = scores_per_voxel - 0.5
corrected_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/cross_cs+_cs-_corrected'

h5save(corrected_file,corrected_per_voxel)
nimg = map2nifti(fds, corrected_per_voxel)
nii_file = corrected_file+'.nii.gz'
nimg.to_filename(nii_file)

# smooth for second level
corrected_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/cross_cs+_cs-_corrected.nii.gz'

smooth_map = image.smooth_img(corrected_file, fwhm=8)
smooth_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/cross_cs+_cs-_smoothed.nii.gz'
smooth_map.to_filename(smooth_file)
#unzip for spm analysis
gunzip(smooth_file)
