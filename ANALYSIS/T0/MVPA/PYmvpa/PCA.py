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
from scipy import linalg
#import seaborn as sns

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

from sklearn.model_selection import train_test_split

# ---------------------------- Script arguments
#subj = str(sys.argv[1])
subj = '01'
#task = str(sys.argv[2])
task = 'hedonic'

#model = str(sys.argv[3])
model = 'MVPA-04'

runs2use = 1 ##??


# class_dict = {
#         'empty' : 0,
#         'chocolate' : 1,
#         'neutral' : 1,  #watcha
#     }


# if model == 'MVPA-02':
#     class_dict = {
#         'empty' : 0,
#         'chocolate' : 1,
#     }

# if model == 'MVPA-03' or model == 'MVPA-05':
#     class_dict = {
#         'neutral' : 0,
#         'chocolate' : 1,
#     }

# mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'

# if model == 'MVPA-05':
#     mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'


# if model == 'MVPA-04':
#     mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'



# # #which ds to use and which mask to use
# sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']
# #shuffle(sub_list)  #training set
# #sub_list=sub_list[0:19]
# # #sampling with replacement
# # sub_list = random.choices(slist, k=19)



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
#         full_fds = fds[i]
#     else:
#         full_fds = vstack([full_fds,fds[i]])
def explained_variance(X, W):
    """
    We compute explained variance from the principal directions W using the
    principle that W are the eigenvectors for the covariance matrix dot(X.T,
    X).
    """
    mean = np.mean(X, axis=0)
    _X = X - mean
    W = W / np.sqrt((W ** 2).sum(axis=1)[:, np.newaxis])
    g = np.dot(W, W.T)
    X_red = np.dot(linalg.pinv(g), np.dot(W, _X.T))
    return (X_red ** 2).sum() / X.shape[0]

def bench(func, data, n=10):
    """
    Benchmark a given function. The function is executed n times and
    its output is expected to be of type datetime.datetime.
    All values are converted to seconds and returned in an array.
    Parameters
    ----------
    func: function to benchmark
    data: tuple (X, y, T, valid) containing training (X, y) and validation (T, valid) data.
    Returns
    -------
    D : array, size=n-2
    """
    assert n > 2
    score = np.inf
    try:
        time = []
        for i in range(n):
            score, t = func(*data)
            time.append(dtime_to_seconds(t))
        # remove extremal values
        time.pop(np.argmax(time))
        time.pop(np.argmin(time))
    except Exception as detail:
        print '%s error in function %s: ' % (repr(detail), func)
        time = []
    return score, np.array(time)

save_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/full_fds'
#save(full_fds, save_file)
full_fds = h5load(save_file)

balancer  = Balancer(attr='targets',count=1,apply_selection=True)
fds = list(balancer.generate(full_fds))
fds = fds[0]

n_components = 16
clf = PCAMapper(output_dim=n_components)
clf.train(fds)
ev = explained_variance(fds.samples, clf.proj.T).sum()
print ev
score, res_pymvpa = misc.bench(bench_pymvpa, fds)
print "PyMVPA: mean %s, std %s" % (np.mean(res_pymvpa), np.std(res_pymvpa))
print "Explained variance: %s\n" % score

#partitioned_ds.select(partitions=[1, 2])

# clfsvm = LinearCSVMC()

# rfesvm = RFE(clfsvm.get_sensitivity_analyzer(postproc=maxofabs_sample()),
#                 CrossValidation(
#                     clfsvm,
#                     NFoldPartitioner(),
#                     errorfx=mean_mismatch_error, postproc=mean_sample()), #errorfx=lambda p, t: np.mean(p == t), postproc=mean_sample()),
#                 Repeater(2),
#                 fselector=FractionTailSelector(0.50, mode='select', tail='upper'), #select 50% of best each step
#                 stopping_criterion=NBackHistoryStopCrit(BestDetector(), 10), # and stop whenever error didn't improve for up to 10 steps
#                 update_sensitivity=True)

# fclfsvm = FeatureSelectionClassifier(clfsvm, rfesvm) #This is nothing but a MappedClassifier

# sensanasvm = fclfsvm.get_sensitivity_analyzer(postproc=maxofabs_sample())


# # manually repeating/splitting so we do both RFE sensitivity and classification
# senses, errors = [], []
# for i, pset in enumerate(NFoldPartitioner().generate(full_fds)):
#     # split partitioned dataset
#     split = [d for d in Splitter('partitions').generate(pset)]
#     senses.append(sensanasvm(split[0])) # and it also should train the classifier so we would ask it about error
#     errors.append(mean_mismatch_error(fclfsvm.predict(split[1]), split[1].targets))

# senses = vstack(senses)
# errors = vstack(errors)




# #     delta = datetime.now() - start
# #     ev = explained_variance(X, clf.proj.T).sum()
# #     print len(fds.fa.voxel_indices)
# #     #map2 = ChainMapper([PCAMapper(reduce=True)]) #,StaticFeatureSelection(slice(None,numPCA))]) # perform singular value decomposition then select first 2 dimensions.
# #     clf1 = LinearCSVMC() #[Default: -1.0] when C is high it will classify all the data points correctly, also there is a chance to overfit.
# #     param_C = [0.1,1, 10, 100]]
# #     param_PCA = [1,5, 10, 15]]
# #     param_best = -np.inf
# #     C_best = 0.0
# #     PCA_best = 0.0
# #     i = 0
# #     for x in param_C:
# #         j = 0
# #             for y in param_PCA:
# #                 ###blablabla
# #                     if XXX[i, j] > param_best:
# #                         param_best = XXX[i, j]
# #                             C_best = x
# #                             PCA_best = y
# #                         print x,y,lml_best
# #                         pass
# #                 j += 1
# #                 pass
# #             i += 1
# #             pass    

# #     # Log marginal likelihood contour plot:
# # pl.figure()
# # X = np.repeat(sigma_noise_steps[:, np.newaxis], sigma_noise_steps.size,
# #              axis=1)
# # Y = np.repeat(length_scale_steps[np.newaxis, :], length_scale_steps.size,
# #              axis=0)
# # step = (lml.max()-lml.min())/30
# # pl.contour(X, Y, lml, np.arange(lml.min(), lml.max()+step, step),
# #               colors='k')
# # pl.plot([sigma_noise_best], [length_scale_best], "k+",
# #            markeredgewidth=2, markersize=8)
# # pl.xlabel("noise standard deviation")
# # pl.ylabel("characteristic length_scale")
# # pl.title("log marginal likelihood")
# # pl.axis("tight")
# # print "lml_best", lml_best
# # print "sigma_noise_best", sigma_noise_best
# # print "length_scale_best", length_scale_best
# # print "number of expected upcrossing on the unitary intervale:", \
# #       1.0/(2*np.pi*length_scale_best)      
   