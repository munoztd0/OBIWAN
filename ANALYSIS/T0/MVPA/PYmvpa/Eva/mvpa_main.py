#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: logancross

modified by David on June 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

from mvpa2.suite import *
import matplotlib.pyplot as plt
from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
from mvpa2.datasets.miscfx import remove_invariant_features ##
import sys
from sh import gunzip
from nilearn import image ## was missing this line!

import os
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils


# ---------------------------- Script arguments
#subj = str(sys.argv[1])
subj = '01'

#task = str(sys.argv[2])
task = 'hedonic'

#model = str(sys.argv[3])
model = 'MVPA-04'
runs2use = 1 ##??

#SVM classifier
clf = LinearCSVMC()
##if model == 'MVPA-05':
    #clf = kNN()

print 'subject id:', subj

print 'smell VS no smell MVPA'

#which ds to use and which mask to use

glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
#mask_name = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/anat/sub-'+subj+'_ses-second_run-01_T1w_reoriented_brain_mask.nii'
mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'

#customize how trials should be labeled as classes for classifier
#timing files 1
#f model == 'MVPA-01':

class_dict = {
        'empty' : 0,
        'chocolate' : 1,
        'neutral' : 1,  #watcha
    }


if model == 'MVPA-02':
    class_dict = {
        'empty' : 0,
        'chocolate' : 1,
    }

if model == 'MVPA-03' or model == 'MVPA-05':
    class_dict = {
        'neutral' : 0,
        'chocolate' : 1,
    }
if model == 'MVPA-05':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'

if model == 'MVPA-04':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Others/PIRIF.nii'
    
###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task)
##WHATCHA was fds 1
#fds2 = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict07, homedir, model)
#lot_mtx

#basic preproc: detrending [likely not necessary since we work with HRF in GLM]
detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
detrended_fds = fds.get_mapped(detrender)

#basic preproc: zscoring (this is critical given the design of the experiment)
zscore(detrended_fds)
fds_z = detrended_fds


#print fds.a.mapper
#pring fds_z.a.mapper


#use a balancer to make a balanced dataset of even amounts of samples in each class
#if model == 'MVPA-01':
balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
##WHATCHA

# Removing inv features #pleases the SVM but messes up dimensions. ##triplecheck
fds = remove_invariant_features(fds_z)

if model == 'MVPA-05' or model == 'MVPA-04':
    fds = (fds_z)


#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
#if model == 'MVPA-01':
cv = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))

if model == 'MVPA-03' or model == 'MVPA-05':
    cv = CrossValidation(clf, NFoldPartitioner(), errorfx=lambda p, t: np.mean(p == t))
#cv = CrossValidation(clf, NFoldPartitioner(1), errorfx=lambda p, t: np.mean(p == t))
#no balance!


#implement full brain searchlight with spheres with a radius of 3
svm_sl = sphere_searchlight(cv, radius=3, space='voxel_indices',postproc=mean_sample())

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]
    

# ---------------------------- Save for perm
#res_sl = svm_sl(fds) 
res_sl = svm_sl(fds) #Obtained degenerate data with zero norm for trainin

#reverse map scores back into nifti format and save
scores_per_voxel = res_sl.samples

vector_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell'
h5save(vector_file,scores_per_voxel)
nimg = map2nifti(fds, scores_per_voxel) ## watcha !!
unsmooth_file = vector_file+'.nii.gz'
nimg.to_filename(unsmooth_file)

# smooth for second level
smooth_map = image.smooth_img(unsmooth_file, fwhm=4) ##!was 8
smooth_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_smoothed.nii.gz'
smooth_map.to_filename(smooth_file)
#unzip for spm analysis
#gunzip(smooth_file)

# ---------------------------- Save for quik ttest

# correct against chance level (0.5)
corrected_per_voxel = scores_per_voxel - 0.5
corrected_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_corrected'

# h5save(corrected_file,corrected_per_voxel)
nimg = map2nifti(fds, corrected_per_voxel)
unsmooth_corrected_file =  corrected_file+'.nii.gz'
nimg.to_filename(unsmooth_corrected_file)

# # # smooth for second level

smooth_map = image.smooth_img(unsmooth_corrected_file, fwhm=4) ##!was 8
smooth_corrected_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_corrected_smoothed.nii.gz'
smooth_files = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/*.nii.gz'
smooth_map.to_filename(smooth_corrected_file)
#unzip for spm analysis
gunzip(smooth_files)

error_sample = np.mean(cv(fds))

print 'error across splits'
print error_sample
print 'end'
