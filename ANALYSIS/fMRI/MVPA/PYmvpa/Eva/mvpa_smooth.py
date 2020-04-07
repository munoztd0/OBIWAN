#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2020

@author: davidmunoz

"""

from mvpa2.suite import *
import matplotlib.pyplot as plt
##from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
from mvpa2.datasets.miscfx import remove_invariant_features ##
import sys
from sh import gunzip
from nilearn import image ## was missing this line!
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn
import os
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils

# ---------------------------- Script arguments
##subj = '01'
subj = str(sys.argv[1])
#task = 'hedonic'
task = str(sys.argv[2])
##model = 'MVPA-01'
model = str(sys.argv[3])
runs2use = 1 ##??


# smooth for second level
corrected_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell.nii.gz'

smooth_map = image.smooth_img(corrected_file, fwhm=4) ##!was 8
smooth_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_smoothed.nii.gz'
smooth_map.to_filename(smooth_file)
#unzip for spm analysis
gunzip(smooth_file)