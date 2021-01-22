
#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: created by David on June 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings, sys, os
warnings.warn = warn
import matplotlib; matplotlib.use('agg') #for server
import matplotlib.pyplot as plt
import seaborn as sns
from mvpa2.suite import *
import pandas as pd  
import numpy as np  
#from sklearn.svm import SVC 
from sklearn.svm import LinearSVC 
from sklearn.metrics import classification_report, confusion_matrix  
#hyperparmeter
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline

homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils

subj = str(sys.argv[1])
task = str(sys.argv[2])
#model = str(sys.argv[3])

subj = '01'
task = 'hedonic'
model = 'MVPA-04'
runs2use = 1 ##??
repeater = 20 #0 #0 #200 perms
rangeX = 100 #number of different components that we want to test np.linspace(2, nSample, rangeX, dtype= int) 
# upper bound is the number of sample in the training set

if model == 'MVPA-04':
    mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

class_dict = {
        'empty' : 0,
        'chocolate' : 1,
        'neutral' : 1,  #watcha
    }


# 80% for train
sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21'] #,'22','23','24','25','26']
#shuffle(sub_list)  #training set
#sub_list=sub_list[0:19]
# #sampling with replacement
# sub_list = random.choices(slist, k=19)

print 'doing train ds'

# glm_ds_file = []
# fds = []

# for i in range(0,len(sub_list)):
#     subj = sub_list[i]
#     print 'working on subject:', subj
#     glm_ds_file.append(homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
#     #use make_targets and class_dict for timing files 1
#     fds_tmp = mvpa_utils.make_targetsFULL(subj, glm_ds_file[i], mask_name, runs2use, class_dict, homedir,  model, task)
    
#     #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
#     detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
#     detrended_fds = fds_tmp.get_mapped(detrender)

#     #basic preproc: zscoring (this is critical given the design of the experiment)
#     zscore(detrended_fds)
#     fds_z = detrended_fds
    
#     # Removing inv features #pleases the SVM but  ##triplecheck
#     fds_temp = remove_invariant_features(fds_z)

#     fds.append(fds_tmp)

#     if len(fds) == 1:
#         train_ds = fds[i]
#     else:
#         train_ds = vstack([train_ds,fds[i]])



train_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/train_ds'
#save(train_ds, train_file)
train_ds = h5load(train_file)


# 20% test
sub_list=['22','23','24','25','26']

print 'doing test ds'

# glm_ds_file = []
# fds = []

# for i in range(0,len(sub_list)):
#     subj = sub_list[i]
#     print 'working on subject:', subj
#     glm_ds_file.append(homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
#     #use make_targets and class_dict for timing files 1
#     fds_tmp = mvpa_utils.make_targetsFULL(subj, glm_ds_file[i], mask_name, runs2use, class_dict, homedir,  model, task)
    
#     #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
#     detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
#     detrended_fds = fds_tmp.get_mapped(detrender)

#     #basic preproc: zscoring (this is critical given the design of the experiment)
#     zscore(detrended_fds)
#     fds_z = detrended_fds
    
#     # Removing inv features #pleases the SVM but  ##triplecheck
#     fds_temp = remove_invariant_features(fds_z)

#     fds.append(fds_tmp)

#     if len(fds) == 1:
#         test_ds = fds[i]
#     else:
#         test_ds = vstack([test_ds,fds[i]])



test_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/test_ds'
#save(test_ds, test_file)
test_ds = h5load(test_file)


#full_fds = h5load(save_file)

#load_file =  homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'

bestPCA = []
bestC = []
bestAccTr = []
bestAccTe = []
bestStdTe = []

for n in range(1,repeater):

    print 'doing repetition', n
    balancer  = Balancer(attr='targets',count=1,apply_selection=True)
    train = list(balancer.generate(train_ds))
    train = train[0]

    X_train = train.samples
    y_train = train.targets


    test = list(balancer.generate(test_ds))
    test = test[0]

    X_test = test.samples
    y_test = test.targets

    #X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.20)
    maxPCA = 455 #len(X_train)

    # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.
    pca = PCA()
    svm = LinearSVC()
    pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])


    # Parameters of pipelines can be set using separated parameter names
    param_grid = {
        'PCA__n_components': np.linspace(2, maxPCA, rangeX, dtype= int), #[5, 15, 30, 45, 64],
        'SVM__C': [0.1, 1, 5, 10, 50, 100],
    }

    #param_grid = {'C': [0.1, 1, 10, 100]} #why negative regulator in pyMVPA?? #param_grid = {'C': [0.1,1, 10, 100], 'gamma': [1,0.1,0.01,0.001],'kernel': ['rbf', 'poly', 'sigmoid']}
    grid = GridSearchCV(pipe, param_grid) #,refit=True,verbose=2)
    grid.fit(X_train,y_train)
    print(grid.best_estimator_)


    grid_predictions = grid.predict(X_test)
    print(confusion_matrix(y_test,grid_predictions))
    print(classification_report(y_test,grid_predictions))

    dict0 = grid.best_params_
    nPCA = dict0.get('PCA__n_components')
    print 'best PCA compinent', nPCA
    nC = dict0.get('SVM__C')
    print 'best SCM C regulator', nC

    bestPCA.append(nPCA)
    bestC.append(nC)

    bAcTr = grid.best_score_
    bAcTe = grid_predictions.mean()
    print 'best Accuracy in test', bAcTe

    bSdTe = grid_predictions.std()

    bestAccTr.append(bAcTr)
    bestAccTe.append(bAcTe)
    bestStdTe.append(bSdTe)


bPCA = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/bestPCA.tsv'
np.savetxt(bPCA, bestPCA, delimiter='\t', fmt='%f')  

bC = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/bestRegC.tsv'
np.savetxt(bC, bestC, delimiter='\t', fmt='%f')  

AccTr = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/AccTrain.tsv'
np.savetxt(AccTr, bestAccTr, delimiter='\t', fmt='%f')  

AccTe = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/AccTest.tsv'
np.savetxt(AccTe, bestAccTe, delimiter='\t', fmt='%f')   

StdTe = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/StdTest.tsv'
np.savetxt(StdTe, bestStdTe, delimiter='\t', fmt='%f')  