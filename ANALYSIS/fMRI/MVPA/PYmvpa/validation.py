#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed May 29 10:31:37 2019

@author: evapool

modified by David on June 13 2020
"""

def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

import matplotlib; matplotlib.use('agg') #for server
from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
import seaborn as sns
#from mvpa2.measures.searchlight import sphere_searchlight

# import subprocess
# import shlex

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

mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'

if model == 'MVPA-05':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'


if model == 'MVPA-04':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'
    
#which ds to use and which mask to use
sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']

res_cv1 = []
res_cv2 = []
res_cv3 = []
res_cv4 = []

for sub in range(0,len(sub_list)):
    subj = sub_list[sub]
    print 'working on subject:', subj
    glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
    #use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
    fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task)

    #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
    detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
    detrended_fds = fds.get_mapped(detrender)

    


    #basic preproc: zscoring (this is critical given the design of the experiment)
    zscore(detrended_fds)
    fds_z = detrended_fds
    
    # Removing inv features #pleases the SVM but  ##triplecheck
    fds = remove_invariant_features(fds_z)

    #print fds_z.a.mapper
    #use a balancer to make a balanced dataset of even amounts of samples in each class
    balancer  = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
    
    numPCA = 16
    #map2 = ChainMapper([PCAMapper(reduce=True)]) #,StaticFeatureSelection(slice(None,numPCA))]) # perform singular value decomposition then select first 2 dimensions.
    clf1 = LinearCSVMC() #[Default: -1.0]
    #clf2 = kNN()
    
    #clf4 = MappedClassifier(clf2, map2)

    #ssel = StaticFeatureSelection(slice(None,2))
    #fsel = SensitivityBasedFeatureSelection(OneWayAnova(),FixedNElementTailSelector(fs,mode='select',tail='upper'))
    #mapper = ChainMapper([PCAMapper(reduce=True),StaticFeatureSelection(slice(None,numPCA))])
    #StaticFeatureSelection(slice(None,fds.shape[1])),fsel,
    clf3 = MappedClassifier(clf1, PCAMapper(output_dim=numPCA))

    #print clf3


    # #indexes = []    
    # class StoreResults(object):
    #     def __init__(self):
    #         self.storage = []
    #     def __call__(self, data, node, result):
    #         self.storage.append((node.measure.mapper.ca.history,
    #                                 node.measure.mapper.ca.errors)),

    #cv_storage = StoreResults()

    #cross valition 1 
    cv1 = CrossValidation(clf1, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
    #cross valition 2 
    #cv2 = CrossValidation(clf2, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
    #cross valition 3 
    cv3 = CrossValidation(clf3, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
    
    #cv4 = CrossValidation(clf4, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
    #cross valition 4 
    #cv4 = CrossValidation(clf4, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])


    tmp_cv1 =cv1(fds)
    #tmp_cv2 =cv2(fds)
    

    tmp_cv3 =cv3(fds)
    #tmp_cv4 =cv4(fds)
    print np.average(tmp_cv1)
    #print np.average(tmp_cv2)
    print np.average(tmp_cv3)
    #print np.average(tmp_cv4)
    


    res_cv1.append(np.average(tmp_cv1))
    #res_cv2.append(np.average(tmp_cv2))
    res_cv3.append(np.average(tmp_cv3))
    #res_cv4.append(np.average(tmp_cv4))



# print the figure with the results of the cross validation
sns.set_style('darkgrid')

sns.distplot(res_cv1, bins=10,label='SVM')
#sns.distplot(res_cv2, bins=10,label='kNN')
sns.distplot(res_cv3, bins=10,label='SVM with PCA')
#sns.distplot(res_cv4, bins=10,label='kNN with PCA')
plt.legend()
#plt.show()

fname = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/plot_class_PCA16.png'
plt.savefig(fname)
#proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))

res1 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/mvpa/res_cv1_accuracy.csv'
res3 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/mvpa/res_cv2_accuracy.csv'

np.savetxt(res1, res_cv1, delimiter='\t', fmt='%f')   
np.savetxt(res3, res_cv3, delimiter='\t', fmt='%f')  


#balancer zscore is somehow better
