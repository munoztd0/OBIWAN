#!/usr/bin/env python2 -W ignore::DeprecationWarning
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 15:56:35 2019

@author: logancross

modified by david on May 13 2020
"""

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

from mvpa2.suite import *
#from os import listdir
import os
import time
import pylab as pl

# ---------------------------- Aux functions

def make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task):

    start_time = time.time()
    #print 'Starting making targets',time.time() - start_time
    
    onsets_folder = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/timing'
    
    trial_list = []
    trial_categ_list = []
    chunks_list = []
    mask_name = os.path.expanduser(mask_name)
    glm_ds_file = os.path.expanduser(glm_ds_file)
    


    #for run in range(1,4):
    temp_folder = onsets_folder+'/'+model+'_task-'+task
    condition = np.genfromtxt(temp_folder+'_condition.txt',dtype=None)
    onsets = np.genfromtxt(temp_folder+'_All.txt')
    mini_runs = np.genfromtxt(temp_folder+'_runs.txt')

    #get timing for all conditions and sort by this timing
    timing = (onsets[:,0])
    trial_list.append(timing)
    #add a list of trial category as a sample attribute
    trial_categ_list.append(condition)
    #chunks = run*np.ones([len(timing)]) ##watcha
    #chunks = np.ones([len(timing)])
    #chunks_list.append(chunks)
    chunks_list.append(mini_runs)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist] 
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    odor_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=odor_classes, chunks=chunks_allruns, mask=mask_name)

    #fds_subset = fds[:runs2use*len(trials_allruns),:] ##
    #print 'Finished making targets',time.time() - start_time

    return fds #_subset


def make_targetsFULL(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task):

    start_time = time.time()
    #print 'Starting making targets',time.time() - start_time
    
    onsets_folder = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/timing'
    
    trial_list = []
    trial_categ_list = []
    chunks_list = []
    mask_name = os.path.expanduser(mask_name)
    glm_ds_file = os.path.expanduser(glm_ds_file)
    


    #for run in range(1,4):
    temp_folder = onsets_folder+'/'+model+'_task-'+task
    condition = np.genfromtxt(temp_folder+'_condition.txt',dtype=None)
    onsets = np.genfromtxt(temp_folder+'_All.txt')
    mini_runs = np.genfromtxt(temp_folder+'_subj.txt')

    #get timing for all conditions and sort by this timing
    timing = (onsets[:,0])
    trial_list.append(timing)
    #add a list of trial category as a sample attribute
    trial_categ_list.append(condition)
    #chunks = run*np.ones([len(timing)]) ##watcha
    #chunks = np.ones([len(timing)])
    #chunks_list.append(chunks)
    chunks_list.append(mini_runs)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist] 
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    odor_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=odor_classes, chunks=chunks_allruns, mask=mask_name)

    #fds_subset = fds[:runs2use*len(trials_allruns),:] ##
    #print 'Finished making targets',time.time() - start_time

    return fds #_subset




def plot_mtx(mtx, labels, title, skip=5):
    # little helper function to plot dissimilarity matrices
    # if using correlation-distance, we use colorbar range of [0,2]
    pl.figure()
    pl.imshow(mtx, interpolation='nearest')
    pl.xticks(range(len(mtx))[::skip], labels[::skip], rotation=90)
    pl.yticks(range(len(mtx))[::skip], labels[::skip])
    pl.title(title)
    pl.clim((0, 2))
    pl.colorbar()
