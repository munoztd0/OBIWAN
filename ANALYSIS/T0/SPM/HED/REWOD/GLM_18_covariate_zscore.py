#!/usr/bin/env python
# coding: utf-8

"""
Created on Mon Mar 10 14:13:20 2020
@author: David Munoz
"""


# data analysis and wrangling
import pandas as pd
import numpy as np
from scipy import stats 
import os
from pathlib import Path


#addpath
home = str(Path.home())
        

#declare variables
GLM = ("GLM-18")
s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")
taskDIR = ("hedonic")

df1 = []
df2 = []
df3 = []
df4 = []

dfsubj = []

df01 = pd.DataFrame()
df02 = pd.DataFrame()
df03 = pd.DataFrame()
df04 = pd.DataFrame()

#%%
for i in s:
    subj = 'sub-' + i
    covpath = home + '/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/' + subj + '/timing/'
    cov_control = pd.read_table(covpath + GLM + '_task-hedonic_odor_control.txt',sep='\t', header=None)
    cov_neutral = pd.read_table(covpath + GLM + '_task-hedonic_odor_neutral.txt',sep='\t', header=None)
    cov_reward = pd.read_table(covpath + GLM + '_task-hedonic_odor_reward.txt',sep='\t', header=None)


    dfsubj = np.append(dfsubj, i)
    rev_neutral = -1 * cov_neutral
    rev_reward = -1 * cov_reward

    N_R = cov_neutral[0] - cov_reward[0]
    df1 = np.append(df1, N_R.mean())

    R_N = cov_reward[0] - cov_neutral[0]
    df2 = np.append(df2, R_N.mean())

    revN_R = rev_neutral[0] - rev_reward[0]
    df3 = np.append(df3, revN_R.mean())

    revR_N = rev_reward[0] - rev_neutral[0]
    df4 = np.append(df4, revR_N.mean())



#%%      
df01[0] = dfsubj
df02[0] = dfsubj
df03[0] = dfsubj
df04[0] = dfsubj


# mean center BY CONDITION
df01[1] = stats.zscore(df1)
df02[1] = stats.zscore(df2)
df03[1] = stats.zscore(df3)
df04[1] = stats.zscore(df4)


df01.columns = ['subj', 'EMG']
df02.columns = ['subj', 'EMG']
df03.columns = ['subj', 'EMG']
df04.columns = ['subj', 'EMG']



os.chdir(home +'/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/group_covariates')

df01.to_csv('neutral-reward_EMG_zscore.txt',sep='\t', index=False)
df02.to_csv('reward-neutral_EMG_zscore.txt',sep='\t', index=False)

df03.to_csv('REV_neutral-reward_EMG_zscore.txt',sep='\t', index=False)
df04.to_csv('REV_reward-neutral_EMG_zscore.txt',sep='\t', index=False)


print("covariates done")