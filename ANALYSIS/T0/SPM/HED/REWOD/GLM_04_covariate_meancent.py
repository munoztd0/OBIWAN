#!/usr/bin/env python
# coding: utf-8

"""
Created on Mon Jun 10 14:13:20 2019
@author: David Munoz
takes the condition name as input (e.g. lik or int)
"""


cond = 'lik'
    
# data analysis and wrangling
import pandas as pd
import numpy as np
import os
from pathlib import Path


#addpath
home = str(Path.home())
       

#declare variables
GLM = ("GLM-04")
s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")
taskDIR = ("hedonic")

df1 = []
df2 = []
df3 = []
df4 = []
df5 = []

dfsubj = []

df01 = pd.DataFrame()
df02 = pd.DataFrame()
df03 = pd.DataFrame()
df04 = pd.DataFrame()
df05 = pd.DataFrame()


for i in s:
    subj = 'sub-' + i
    covpath = home + '/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/' + subj + '/timing/'
    cov_control = pd.read_table(covpath + GLM + '_task-hedonic_odor_control_' + cond + '.txt',sep='\t', header=None)
    cov_neutral = pd.read_table(covpath + GLM + '_task-hedonic_odor_neutral_' + cond + '.txt',sep='\t', header=None)
    cov_reward = pd.read_table(covpath + GLM + '_task-hedonic_odor_reward_' + cond + '.txt',sep='\t', header=None)

    dfsubj = np.append(dfsubj, i)

    R_C = cov_reward[2] - cov_control[2]
    df1 = np.append(df1, R_C.mean())

    R_N = cov_reward[2] - cov_neutral[2]
    df2 = np.append(df2, R_N.mean())

    Odor_NoOdor= (cov_reward[2] + cov_neutral[2])/2 - cov_control[2]
    df3 = np.append(df3, Odor_NoOdor.mean())

    Odor_presence = (cov_reward[2] + cov_neutral[2])/2
    df4 = np.append(df4, Odor_presence.mean())
    
    Reward_NoReward = cov_reward[2] - (cov_neutral[2] + cov_control[2])/2
    df5 = np.append(df5, Reward_NoReward.mean())
    
 #%%       
    df01[0] = dfsubj
    df02[0] = dfsubj
    df03[0] = dfsubj
    df04[0] = dfsubj
    df05[0] = dfsubj
    
    # mean center BY CONDITION
    df01[1] = df1 - df1.mean()
    df02[1] = df2 - df2.mean()
    df03[1] = df3 - df3.mean()
    df04[1] = df4 - df4.mean()
    df05[1] = df5 - df5.mean()
    
    df01.columns = ['subj', cond]
    df02.columns = ['subj', cond]
    df03.columns = ['subj', cond]
    df04.columns = ['subj', cond]
    df05.columns = ['subj', cond]
    

    os.chdir(home +'/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/group_covariates')
    df01.to_csv('reward-control_' + cond + '_meancent.txt',sep='\t', index=False)
    df02.to_csv('reward-neutral_' + cond + '_meancent.txt',sep='\t', index=False)
    df03.to_csv('Odor-NoOdor_' + cond + '_meancent.txt',sep='\t', index=False)
    df04.to_csv('Odor_presence_' + cond + '_meancent.txt',sep='\t', index=False)
    df05.to_csv('Reward_NoReward_' + cond + '_meancent.txt',sep='\t', index=False)
    
    print("covariates done")