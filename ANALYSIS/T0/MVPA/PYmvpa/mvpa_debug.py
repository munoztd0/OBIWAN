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
#import matplotlib.pyplot as plt
from mvpa2.datasets.miscfx import remove_invariant_features ##
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils


# ---------------------------- Script arguments
#subj = str(sys.argv[1])
#task = str(sys.argv[2])
#model = str(sys.argv[3])

subj = '01'
task = 'hedonic'
model = 'MVPA-04'
runs2use = 1 ##??
perm = 10.0 #0 #200 perms


print 'subject id:', subj

print 'smell VS no smell MVPA perms #', perm

#which ds to use and which mask to use
#load_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/full_fds'
#save(full_fds, save_file)
#full_fds = h5load(save_file)

load_file =  homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
ds = h5load(load_file)


#clf = LinearCSVMC()
SVM = LinearCSVMC(C=-1.0)

clf = MappedClassifier(SVM, PCAMapper(reduce=True)) #output_dim=numPCA

partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')



cv = CrossValidation(
        clf,
        partitioner,
        errorfx=prediction_target_matches,
        postproc=BinomialProportionCI(width=.95, meth='jeffreys'))

cv_result = cv(ds)
acc = np.average(cv_result)
sDev = np.std(cv_result)
ci = cv_result.samples[:, 0]
CIlow = ci[0] 
CIup = ci[1]

print 'Lower CI', CIlow
print "mean accuracy", acc
print 'Upper CI', CIup


repeater = Repeater(count=perm) # more

permutator = AttributePermutator('targets',limit={'partitions': 1},count=1)
null_cv = CrossValidation(clf,ChainNode([partitioner, permutator],space=partitioner.get_space()),postproc=mean_sample())

#MonteCarlo Null distance calculation
distr_est = MCNullDist(repeater, tail='left', measure=null_cv, enable_ca=['dist_samples'])

cv_mc = CrossValidation(clf,partitioner,postproc=mean_sample(),null_dist=distr_est,enable_ca=['stats'])
err = cv_mc(ds)
err1 = np.average(err)
print "error MC", err1



def make_plot(dist_samples, empirical, CIlow, CIup):
        sns.set_style('darkgrid')
        plt.hist(dist_samples, bins=20, normed=True, alpha=0.8, label='Null Distribution')
        plt.axvline(CIlow, color='red', ls='--', alpha=0.5, label='Lower 95% CI')
        plt.axvline(empirical, color='red', label='Empirical average cross-validated classification error ')
        plt.axvline(CIup, color='red', ls='--', alpha=0.5, label='Upper 95% CI')
        plt.axvline(0.5, color='black', ls='--', label='chance-level for a binary classification with balanced samples')
        plt.legend()

fname = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/plot_acc.png'
# fname = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/plot_acc.png'

null_dist = np.ravel(cv_mc.null_dist.ca.dist_samples)
make_plot(null_dist,acc, CIlow, CIup)  #plot


plt.savefig(fname)
# p = np.asscalar(cv_mc.ca.null_prob) #old pval
# print p


pVal = len(np.where(null_dist>=acc)[0])/perm #p_val

nPCA = clf.mapper.node.get_output_dim() #number of pca
table = [acc, CIlow, CIup, sDev, perm,  pVal] #tsv evrything


dist = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/null_dist.tsv'
accu = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/acc_ciL_ciU_sDev_pVal_nPCA_perm.tsv'

np.savetxt(dist, null_dist, delimiter='\t', fmt='%f')   
np.savetxt(accu, table, delimiter='\t', fmt='%f')  





# # print 'end'
