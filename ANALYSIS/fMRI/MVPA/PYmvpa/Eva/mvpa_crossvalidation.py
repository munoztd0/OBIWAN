g#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed May 29 10:31:37 2019

@author: evapool
"""


import sys
# this is just for my own machine
sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/") 


from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
import seaborn as sns
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils_pav
import subprocess
import shlex

ana_name  = 'MVPA-08'
homedir = '/Users/evapool/mountpoint/PAVMOD/'

#add utils to path
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')

###SCRIPT ARGUMENTS
runs2use = 3

class_dict03 = {
		'csm' : 0,
		'csp' : 1,
	}

mask_name = homedir+'DATA/brain/CANONICALS/averaged_T1w_mask.nii'


#which ds to use and which mask to use
sub_list=['01', '03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30']

res_cv1_nz = []
res_cv1_z = []
res_cv2_nz = []
res_cv2_z = []

for sub in range(0,len(sub_list)):
    subj = sub_list[sub]
    print 'working on subject:', subj
    glm_ds_file = homedir+'DATA/brain/MODELS/RSA/MVPA-03_old/sub-'+subj+'/glm/beta_everytrial_pav8/tstat_all_trials_4D.nii'
    #use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
    fds = mvpa_utils_pav.make_targets03(subj, glm_ds_file, mask_name, runs2use, class_dict03, homedir, ana_name)

    #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
    detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
    detrended_fds = fds.get_mapped(detrender)

    #basic preproc: zscoring (this is critical given the design of the experiment)
    zscore(detrended_fds)
    fds_z = detrended_fds
    print fds.a.mapper
    print fds_z.a.mapper
    #use a balancer to make a balanced dataset of even amounts of samples in each class
    balancer  = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
    balancer2  = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=10,limit='partitions',apply_selection=True)],space='partitions')
    #SVM classifier
    clf = LinearCSVMC()
    #cross valition 1 using balancer
    cv1 = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))
    #cross valition 2 without balancer
    cv2 = CrossValidation(clf, balancer2, errorfx=lambda p, t: np.mean(p == t))

    tmp_cv1_nz=cv1(fds)
    tmp_cv1_z =cv1(fds_z)
    print np.average(tmp_cv1_nz)

    tmp_cv2_nz=cv2(fds)
    tmp_cv2_z =cv2(fds_z)

    res_cv1_nz.append(np.average(tmp_cv1_nz))
    res_cv1_z.append(np.average(tmp_cv1_z))
    res_cv2_nz.append(np.average(tmp_cv2_nz))
    res_cv2_z.append(np.average(tmp_cv2_z))



# print the figure with the results of the cross validation
sns.set_style('darkgrid')

sns.distplot(res_cv1_nz, bins=10,label='balancer no zscore')
sns.distplot(res_cv1_z, bins=10,label='balancer zscore')
sns.distplot(res_cv2_z, bins=10,label='no balancer zscore')
sns.distplot(res_cv2_nz, bins=10,label='no balancer no zscore')
plt.legend()

fname = homedir+'ANALYSIS/mvpa_scripts/PYmvpa/crossvalidation_plot3.pdf'
plt.savefig(fname)
proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))

