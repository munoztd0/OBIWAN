#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created by David on June 13 2020
"""

def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

from mvpa2.suite import *
from mvpa2.testing.tools import ok_, assert_array_equal, assert_true, \
        assert_false, assert_equal, assert_not_equal, reseed_rng, assert_raises, \
        assert_array_almost_equal, SkipTest, assert_datasets_equal, assert_almost_equal
#import matplotlib; matplotlib.use('agg') #for server
from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
from mvpa2.datasets.miscfx import remove_invariant_features #
import time
from sh import gunzip
from nilearn import image ## was missing this line!


import os
import sys
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


glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
#mask_name = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/anat/sub-'+subj+'_ses-second_run-01_T1w_reoriented_brain_mask.nii'
mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'

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



print 'subject id:', subj

print 'smell VS no smell MVPA'

#which ds to use and which mask to use


#customize how trials should be labeled as classes for classifier
#timing files 1
#f model == 'MVPA-01':

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

# Removing inv features #pleases the SVM but  ##triplecheck
full_fds = remove_invariant_features(fds_z)


# save_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/full_fds'
# #save(full_fds, save_file)
# full_fds = h5load(save_file)
# #partitioned_ds.select(partitions=[1, 2])

clfsvm = LinearCSVMC()

rfesvm = RFE(clfsvm.get_sensitivity_analyzer(postproc=maxofabs_sample()),
                CrossValidation(
                    clfsvm,
                    NFoldPartitioner(),
                    errorfx=mean_mismatch_error, postproc=mean_sample()), #errorfx=lambda p, t: np.mean(p == t), postproc=mean_sample()),
                Repeater(2),
                fselector=FractionTailSelector(0.50, mode='select', tail='upper'), #select 50% of best each step
                stopping_criterion=NBackHistoryStopCrit(BestDetector(), 10), # and stop whenever error didn't improve for up to 10 steps
                update_sensitivity=True)

fclfsvm = FeatureSelectionClassifier(clfsvm, rfesvm) #This is nothing but a MappedClassifier

sensanasvm = fclfsvm.get_sensitivity_analyzer(postproc=maxofabs_sample())

if __debug__:
    debug.active += [ 'RFEC', 'CLF' ]

# manually repeating/splitting so we do both RFE sensitivity and classification
senses, errors = [], []
for i, pset in enumerate(NFoldPartitioner().generate(full_fds)):
    # split partitioned dataset
    split = [d for d in Splitter('partitions').generate(pset)]
    senses.append(sensanasvm(split[0])) # and it also should train the classifier so we would ask it about error
    errors.append(mean_mismatch_error(fclfsvm.predict(split[1]), split[1].targets))

senses = vstack(senses)
errors = vstack(errors)


# Let's compare against rerunning the beast simply for classification with CV
errors_cv = CrossValidation(fclfsvm, NFoldPartitioner(), errorfx=mean_mismatch_error)(fds)
# and they should match
assert_array_equal(errors, errors_cv)

# buggy!
cv_sensana_svm = RepeatedMeasure(sensanasvm, NFoldPartitioner())
senses_rm = cv_sensana_svm(fds)

print senses.samples, senses_rm.samples
print errors, errors_cv.samples

assert_raises(AssertionError,
                assert_array_almost_equal,
                senses.samples, senses_rm.samples)
raise SkipTest("Known failure for repeated measures: https://github.com/PyMVPA/PyMVPA/issues/117")


#     delta = datetime.now() - start
#     ev = explained_variance(X, clf.proj.T).sum()
#     print len(fds.fa.voxel_indices)
#     #map2 = ChainMapper([PCAMapper(reduce=True)]) #,StaticFeatureSelection(slice(None,numPCA))]) # perform singular value decomposition then select first 2 dimensions.
#     clf1 = LinearCSVMC() #[Default: -1.0] when C is high it will classify all the data points correctly, also there is a chance to overfit.
#     param_C = [0.1,1, 10, 100]]
#     param_PCA = [1,5, 10, 15]]
#     param_best = -np.inf
#     C_best = 0.0
#     PCA_best = 0.0
#     i = 0
#     for x in param_C:
#         j = 0
#             for y in param_PCA:
#                 ###blablabla
#                     if XXX[i, j] > param_best:
#                         param_best = XXX[i, j]
#                             C_best = x
#                             PCA_best = y
#                         print x,y,lml_best
#                         pass
#                 j += 1
#                 pass
#             i += 1
#             pass    

#     # Log marginal likelihood contour plot:
# pl.figure()
# X = np.repeat(sigma_noise_steps[:, np.newaxis], sigma_noise_steps.size,
#              axis=1)
# Y = np.repeat(length_scale_steps[np.newaxis, :], length_scale_steps.size,
#              axis=0)
# step = (lml.max()-lml.min())/30
# pl.contour(X, Y, lml, np.arange(lml.min(), lml.max()+step, step),
#               colors='k')
# pl.plot([sigma_noise_best], [length_scale_best], "k+",
#            markeredgewidth=2, markersize=8)
# pl.xlabel("noise standard deviation")
# pl.ylabel("characteristic length_scale")
# pl.title("log marginal likelihood")
# pl.axis("tight")
# print "lml_best", lml_best
# print "sigma_noise_best", sigma_noise_best
# print "length_scale_best", length_scale_best
# print "number of expected upcrossing on the unitary intervale:", \
#       1.0/(2*np.pi*length_scale_best)      
   