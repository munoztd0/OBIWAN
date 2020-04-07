#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created by David on June 13 2020
"""

def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

import matplotlib; matplotlib.use('agg') #for server
from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
#import seaborn as sns
import random
#from mvpa2.measures.searchlight import sphere_searchlight

# import subprocess
# import shlex

import os
import sys
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils

# ---------------------------- Script arguments
subj = str(sys.argv[1])
#subj = '01'
task = str(sys.argv[2])
#task = 'hedonic'

model = str(sys.argv[3])
#model = 'MVPA-04'

runs2use = 1 ##??

rep = 100 #00
PCA = 10

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



# #which ds to use and which mask to use
sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21'] #,'22','23','24','25','26']
#shuffle(sub_list)  #training set
#sub_list=sub_list[0:19]
# #sampling with replacement
# sub_list = random.choices(slist, k=19)



glm_ds_file = []
fds = []

for i in range(0,len(sub_list)):
    subj = sub_list[i]
    print 'working on subject:', subj
    glm_ds_file.append(homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
    #use make_targets and class_dict for timing files 1
    fds_tmp = mvpa_utils.make_targetsFULL(subj, glm_ds_file[i], mask_name, runs2use, class_dict, homedir,  model, task)
    
    #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
    detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
    detrended_fds = fds_tmp.get_mapped(detrender)

    #basic preproc: zscoring (this is critical given the design of the experiment)
    zscore(detrended_fds)
    fds_z = detrended_fds
    
    # Removing inv features #pleases the SVM but  ##triplecheck
    fds_temp = remove_invariant_features(fds_z)

    fds.append(fds_tmp)

    if len(fds) == 1:
        full_fds = fds[i]
    else:
        full_fds = vstack([full_fds,fds[i]])


#print full_fds.summary()
# part = HalfPartitioner(2)
# split = CustomSplitter([], attr='chunks', selection_strategy='random')
# ptr = CustomPartitioner([(None, [1, 2, 3, 4, 5])], space='partitions')
# split = Partitioner(count=2, selection_strategy='random', attr='chunks')
# ds = list(Splitter('partitions').generate(full_fds))
# partitioned_ds.select(partitions=[1, 2])

#use a balancer to make a balanced dataset of even amounts of samples in each class
# balancer  = Balancer(attr='targets',count=1,apply_selection=True)
# fds[i] = list(balancer.generate(fds[i]))


balancer1  = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
balancer2  = ChainNode([HalfPartitioner(2, selection_strategy='random'),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
 
res_cv1 = []


for boot in range(0,1):
        #print ds[1].summary(chunks_attr='partitions')
    clf1 = LinearCSVMC()
    cv1 = CrossValidation(clf1, balancer1, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
    tmp_cv1 =cv1(full_fds)
    res_cv1.append(np.average(tmp_cv1))
    print 'Boot base', boot



res1 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/res_base_'+str(boot)+'_accuracy.csv'
  
np.savetxt(res1, res_cv1, delimiter='\t', fmt='%f')  
    # x = np.average(tmp_cv1)
    # i = 0

up = 29 - PCA
for numPCA in range(29,up,-1):    #len(sub_list)):
    res_cv2 = []
    for boot in range(0,rep):
    #     numPCA = 16

        #C=1000,
    #     #clf2 = kNN()
        
    #     #clf4 = MappedClassifier(clf2, map2)

    #     #ssel = StaticFeatureSelection(slice(None,2))
    #     #fsel = SensitivityBasedFeatureSelection(OneWayAnova(),FixedNElementTailSelector(fs,mode='select',tail='upper'))
    #     #mapper = ChainMapper([PCAMapper(reduce=True),StaticFeatureSelection(slice(None,numPCA))])
    #     #StaticFeatureSelection(slice(None,fds.shape[1])),fsel,
        clf2 = MappedClassifier(clf1, PCAMapper(output_dim=numPCA))

        cv2 = CrossValidation(clf2, balancer1, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])
        

        tmp_cv2 =cv2(full_fds)

        res_cv2.append(np.average(tmp_cv2))
        print 'PCA %(PCA)d , boot %(boot)d' % {"PCA": numPCA, "boot": boot}

    res2 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/res_'+str(numPCA)+'_'+str(boot)+'_accuracy.csv'

# np.savetxt(res1, res_cv1, delimiter='\t', fmt='%f')   
    np.savetxt(res2, res_cv2, delimiter='\t', fmt='%f')  


    
    #     u = np.average(tmp_cv3)

        
    #     print u

    #     if u - x > 0.5:
    #         x = u
    #         i = 0
    #     else:
    #         i += 1

    #     if i > 10:
    #         break

    # print numPCA



    #     res_cv1.append(np.average(tmp_cv1))
    #     #res_cv2.append(np.average(tmp_cv2))
        
    #     #res_cv4.append(np.average(tmp_cv4))



    # # print the figure with the results of the cross validation
    # sns.set_style('darkgrid')

    # sns.distplot(res_cv1, bins=10,label='SVM')
    # #sns.distplot(res_cv2, bins=10,label='kNN')
    # sns.distplot(res_cv3, bins=10,label='SVM with PCA')
    # #sns.distplot(res_cv4, bins=10,label='kNN with PCA')
    # plt.legend()
    # #plt.show()

    # fname = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/plot_class_PCA16.png'
    # plt.savefig(fname)
    # #proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))

# res1 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/mvpa/res_cv1_accuracy.csv'



# #balancer zscore is somehow better
