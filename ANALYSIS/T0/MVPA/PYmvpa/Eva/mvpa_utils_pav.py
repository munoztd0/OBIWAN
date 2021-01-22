#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 15:56:35 2019

@author: logancross

modified by eva on May 13 2019
"""
from mvpa2.suite import *
from os import listdir
import time


# ---------------------------- Aux functions

def make_targets08(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time

    onsets_folder = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/timing/'

    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+ana_name+'_run-0'+str(run)
        condition = np.genfromtxt(temp_folder+'_condition.txt',dtype=None)
        onsets = np.genfromtxt(temp_folder+'_ALL.txt')

        #get timing for all conditions and sort by this timing
        timing = (onsets[:,0])
        trial_list.append(timing)
        #add a list of trial category as a sample attribute
        trial_categ_list.append(condition)
        chunks = run*np.ones([len(timing)])
        chunks_list.append(chunks)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist] 
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    cs_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=cs_classes, chunks=chunks_allruns, mask=mask_name)

    fds_subset = fds[:runs2use*120,:]

    print 'Finished making targets',time.time() - start_time

    return fds_subset



def make_targets05(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time

    onsets_folder = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/timing/'

    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+ana_name+'_run-0'+str(run)
        condition = np.genfromtxt(temp_folder+'_condition.txt',dtype=None)
        onsets = np.genfromtxt(temp_folder+'_CS_plus.txt')

        #get timing for all conditions and sort by this timing
        timing = (onsets[:,0])
        trial_list.append(timing)
        #add a list of trial category as a sample attribute
        trial_categ_list.append(condition)
        chunks = run*np.ones([len(timing)])
        chunks_list.append(chunks)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist]
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    cs_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=cs_classes, chunks=chunks_allruns, mask=mask_name)

    fds_subset = fds[:runs2use*40,:]

    print 'Finished making targets',time.time() - start_time

    return fds_subset

def make_targets03(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time

    onsets_folder = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/timing/'

    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+ana_name+'_run-0'+str(run)
        csm_onsets = np.genfromtxt(temp_folder+'_CS_minus.txt')
        csp_onsets = np.genfromtxt(temp_folder+'_CS_plus.txt')

        #get timing for all conditions and sort by this timing
        timing = np.concatenate((csm_onsets[:,0], csp_onsets[:,0]))
        #add a list of trial category as a sample attribute
        trial_categ_unsort = [['csm' for c in range(len(csm_onsets))],['csp' for c in range(len(csp_onsets))]]
        trial_categ_unsort = [item for sublist in trial_categ_unsort for item in sublist]
        #sort by trial timing and append to lists
        sort_time_inds = np.argsort(timing)
        all_trials = np.concatenate((csm_onsets, csp_onsets))
        all_trials = all_trials[sort_time_inds,:]
        trial_list.append(all_trials)
        trial_categ = [trial_categ_unsort[ind] for ind in sort_time_inds]
        trial_categ_list.append(trial_categ)
        chunks = run*np.ones([len(all_trials)])
        chunks_list.append(chunks)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist]
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    cs_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=cs_classes, chunks=chunks_allruns, mask=mask_name)

    fds_subset = fds[:runs2use*60,:]

    print 'Finished making targets',time.time() - start_time

    return fds_subset



def make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time

    onsets_folder = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/timing/'

    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+ana_name+'_run-0'+str(run)
        csm_onsets = np.genfromtxt(temp_folder+'_CS_CSm.txt')
        cs_deval_onsets = np.genfromtxt(temp_folder+'_CS_deval.txt')
        cs_val_onsets = np.genfromtxt(temp_folder+'_CS_val.txt')

        #get timing for all conditions and sort by this timing
        timing = np.concatenate((csm_onsets[:,0], cs_deval_onsets[:,0], cs_val_onsets[:,0]))
        #add a list of trial category as a sample attribute
        trial_categ_unsort = [['csm' for c in range(len(csm_onsets))],['cs_deval' for c in range(len(cs_deval_onsets))],['cs_val' for c in range(len(cs_val_onsets))]]
        trial_categ_unsort = [item for sublist in trial_categ_unsort for item in sublist]
        #sort by trial timing and append to lists
        sort_time_inds = np.argsort(timing)
        all_trials = np.concatenate((csm_onsets, cs_deval_onsets, cs_val_onsets))
        all_trials = all_trials[sort_time_inds,:]
        trial_list.append(all_trials)
        trial_categ = [trial_categ_unsort[ind] for ind in sort_time_inds]
        trial_categ_list.append(trial_categ)
        chunks = run*np.ones([len(all_trials)])
        chunks_list.append(chunks)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist]
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    cs_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=cs_classes, chunks=chunks_allruns, mask=mask_name)

    fds_subset = fds[:runs2use*60,:]

    print 'Finished making targets',time.time() - start_time

    return fds_subset


def make_targets2(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, ana_name):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time

    onsets_folder = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/glm/timing/'

    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+ana_name+'_run-0'+str(run)
        csm_onsets = np.genfromtxt(temp_folder+'_CS_CSm.txt')
        cs_deval_L_onsets = np.genfromtxt(temp_folder+'_CS_deval_L.txt')
        cs_deval_R_onsets = np.genfromtxt(temp_folder+'_CS_deval_R.txt')
        cs_val_L_onsets = np.genfromtxt(temp_folder+'_CS_val_L.txt')
        cs_val_R_onsets = np.genfromtxt(temp_folder+'_CS_val_R.txt')

        #get timing for all conditions and sort by this timing
        timing = np.concatenate((csm_onsets[:,0], cs_deval_L_onsets[:,0], cs_deval_R_onsets[:,0], cs_val_L_onsets[:,0], cs_val_R_onsets[:,0]))
        #add a list of trial category as a sample attribute
        trial_categ_unsort = [['csm' for c in range(len(csm_onsets))],['cs_deval_L' for c in range(len(cs_deval_L_onsets))],['cs_deval_R' for c in range(len(cs_deval_R_onsets))],
                               ['cs_val_L' for c in range(len(cs_val_L_onsets))], ['cs_val_R' for c in range(len(cs_val_R_onsets))]]
        trial_categ_unsort = [item for sublist in trial_categ_unsort for item in sublist]
        #sort by trial timing and append to lists
        sort_time_inds = np.argsort(timing)
        all_trials = np.concatenate((csm_onsets, cs_deval_L_onsets, cs_deval_R_onsets, cs_val_L_onsets, cs_val_R_onsets))
        all_trials = all_trials[sort_time_inds,:]
        trial_list.append(all_trials)
        trial_categ = [trial_categ_unsort[ind] for ind in sort_time_inds]
        trial_categ_list.append(trial_categ)
        chunks = run*np.ones([len(all_trials)])
        chunks_list.append(chunks)

    #unroll lists of lists to one list
    trials_allruns = np.asarray([item for sublist in trial_list for item in sublist])
    trial_categ_allruns = [item for sublist in trial_categ_list for item in sublist]
    chunks_allruns = np.asarray([item for sublist in chunks_list for item in sublist]).astype(int)

    cs_classes = [class_dict[trial] for trial in trial_categ_allruns]

    #load fmri dataset with these values as targets
    fds = fmri_dataset(samples=glm_ds_file, targets=cs_classes, chunks=chunks_allruns, mask=mask_name)

    fds_subset = fds[:runs2use*60,:]

    print 'Finished making targets',time.time() - start_time

    return fds_subset

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
