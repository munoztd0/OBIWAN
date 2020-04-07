#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 15:56:35 2019

@author: logancross
"""
from mvpa2.suite import *
from os import listdir
import time

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
    
    print 'changes happened4'
    fds.sa['trial_type'] = trial_categ_allruns
    
    fds_subset = fds[:runs2use*60,:]
    
    print 'Finished making targets',time.time() - start_time
    
    #return fds_subset, trial_categ_allruns[:runs2use*60]
    return fds_subset

def make_targets2(subj, glm_ds_file, mask_name, runs2use, class_dict):

    start_time = time.time()
    print 'Starting making targets',time.time() - start_time
    
    onsets_folder = '/Users/logancross/Documents/EvaPavlovian/analysis/timing_files2/sub-'+subj+'/'
    
    trial_list = []
    trial_categ_list = []
    chunks_list = []
    for run in range(1,4):
        temp_folder = onsets_folder+'GLM-02_run-0'+str(run)
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
    
class CrossDecodingFilter(Node):
    def __init__(self, target_groups, part_attr, target_attr,
                 space='filtered_partitions', **kwargs):
        self._target_groups = target_groups
        self._target_attr = target_attr
        self._part_attr = part_attr
        Node.__init__(self, space=space, **kwargs)
        
    def generate(self, ds):
        # binary mask for training and testing ortion
        train_part = ds.sa[self._part_attr].value == 1
        test_part = ds.sa[self._part_attr].value == 2
        # binary mask for the first and second target group
        match_1st_group = [t in self._target_groups[0]
                for t in ds.sa[self._target_attr].value]
        match_2nd_group = [t in self._target_groups[1]
                for t in ds.sa[self._target_attr].value]
        match_3rd_group = [t in self._target_groups[2]
                for t in ds.sa[self._target_attr].value]

        # in the first to-be-returned dataset we will blank out
        # group1 in the training set and group2 in the testing set
        #LOGAN: we will also blank out group 3 in the testing set since we only want to train on it
        # Note: setting the partition value to zero, will cause the Splitter
        # employed in the CrossValidation Measure to ignore the corresponding
        # samples
        new_part = ds.sa[self._part_attr].value.copy()
        new_part[np.logical_and(train_part, match_1st_group)] = 0
        new_part[np.logical_and(test_part, match_2nd_group)] = 0
        new_part[np.logical_and(test_part, match_3rd_group)] = 0
        ds.sa[self.get_space()] = new_part
        yield ds

        # in the second to-be-returned dataset we will blank out
        # group2 in the training set and group1 in the testing set
        new_part = ds.sa[self._part_attr].value.copy()
        new_part[np.logical_and(train_part, match_2nd_group)] = 0
        new_part[np.logical_and(test_part, match_1st_group)] = 0
        new_part[np.logical_and(test_part, match_3rd_group)] = 0
        ds.sa[self.get_space()] = new_part
        yield ds
    