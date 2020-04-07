#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 21 13:24:15 2019

@author: evapool

Creates accuracy maps minus chance maps for every subject (H0: accuracy=50%) to
do a quick second level analysis

"""

from mvpa2.suite import *
import matplotlib.pyplot as plt
from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
import sys
# import utilities
homedir = '/home/eva/PAVMOD/'
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')
os.chdir(homedir+'ANALYSIS/mvpa_scripts/PYmvpa')
import mvpa_utils_pav
from sh import gunzip


# ---------------------------- input

ana_name  = 'MVPA-03'
subj = str(sys.argv[1])
print 'subject id: ', subj

runs2use = 3

#----------------------------- get fds

#which ds to use and which mask to use
#glm_ds_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/beta_everytrial_pav/tstat_all_trials_4D.nii'
#mask_name   = homedir+'DATA/brain/MODELS/SPM/GLM-MF-09a/sub-'+subj+'/output/mask.nii'

#customize how trials should be labeled as classes for classifier
#timing files 1
class_dict = {
		'csm' : 0,
		'cs_deval' : 1,
		'cs_val' : 1,
	}

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
#fds = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name)


# ---------------------------- load the hdf5 data

#vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-'
#scores_per_voxel = h5load(vector_file)

# ---------------------------- substract the chance level

#corrected_per_voxel = scores_per_voxel - 0.5

# ---------------------------- save
corrected_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-_corrected'

#h5save(corrected_file,corrected_per_voxel)
#nimg = map2nifti(fds, corrected_per_voxel)
nii_file = corrected_file+'.nii.gz'
#nimg.to_filename(nii_file)

# ---------------------------- save
#corrected_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-_corrected.nii.gz'
#smooth_map = image.smooth_img(corrected_file, fwhm=8)
#smooth_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-_smoothed.nii.gz'
#smooth_map.to_filename(smooth_file)

 # ---------------------------- unzip for spm analysis
# gunzip(smooth_file)
gunzip(nii_file)
