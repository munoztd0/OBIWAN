#!/usr/bin/env python2
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
import scipy


ana_name  = 'MVPA-03'
homedir = '/Users/evapool/mountpoint/PAVMOD/'

#add utils to path
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')

###SCRIPT ARGUMENTS
runs2use = 2

class_dict03 = {
		'csm' : 0,
		'csp' : 1,
	}

class_dict07 = {
		'cs_sweet_L' : 0,
		'cs_sweet_R' : 0,
        'cs_salty_L': 1,
        'cs_salty_R': 1,
	}

# defaault whole brain mask
mask_name = homedir+'DATA/brain/CANONICALS/averaged_T1w_mask.nii'


sub_list=['01', '03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30']


roi_list= ['INSleftROI', 'INSrightROI', 'LOCleftROI', 'LOCrightROI', 'SMAROI', 'VSrightROI', 'VSleftROI', 'VSROI', 'VTAROI', 'vmPFC']



for roi in range (0,len(roi_list)):
    
    # get the roi of interest
    roix = roi_list[roi] 
    mask_name = homedir+'/DATA/brain/ROI/GLM-MF-09a/clusters/'+roix+'.nii'

    # initialize variable for plots after each
    res_cv1_nz = []
    res_cv1_z = []
    
    print res_cv1_nz
    print res_cv1_z

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
   
        #SVM classifier
        clf = LinearCSVMC()
        #cross valition 1 using balancer
        cv1 = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))
  
        tmp_cv1_nz=cv1(fds)
        tmp_cv1_z =cv1(fds_z)
        print np.average(tmp_cv1_z)
        print np.average(tmp_cv1_nz)
        
        res_cv1_nz.append(np.average(tmp_cv1_nz))
        res_cv1_z.append(np.average(tmp_cv1_z))

        t_nz = scipy.stats.ttest_1samp(res_cv1_nz, 0.5)
        t_z = scipy.stats.ttest_1samp(res_cv1_z, 0.5)

    # print the figure with the results of the cross validation
    print 'making plot for {}'.format(roix)
    fig = plt.figure()
    sns.set_style('darkgrid')
    labelX = roix+ ': t = {}, p = {}'.format(*t_nz)
    sns.distplot(res_cv1_nz, bins=10,label= labelX)
    plt.vlines(np.average(res_cv1_z), 0,10, linestyles='solid')
    labelX = roix+ ': t = {}, p = {}'.format(*t_z)
    sns.distplot(res_cv1_z, bins=10,label=' zscore ' +labelX)
    plt.vlines(np.average(res_cv1_z), 0,10, linestyles='dashed')
    plt.legend()
    fname = homedir+'ANALYSIS/mvpa_scripts/PYmvpa/cross_decoding/crossvalidation_'+roix+'_2runs.pdf'
    plt.savefig(fname)
    proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))
    plt.close(fig)

