#!/usr/bin/env python
# coding: utf-8

"""
Created on Mon Jun 10 14:13:20 2019

@author: David Munoz

takes the condition name as input ('eff')
"""

def covariate (cond):
    # data analysis and wrangling
    import pandas as pd
    import numpy as np
    import os
    from pathlib import Path
    
    cond = 'eff'
    
    #addpath
    home = str(Path.home())
    
    
    #declare variables
    GLM = ("GLM-04")
    s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")
    taskDIR = ("PIT")
    
    df1 = []
    df2 = []
    df3 = []
    
    dfsubj = []
    
    df01 = pd.DataFrame()
    df02 = pd.DataFrame()
    df03 = pd.DataFrame()
    
    
    for i in s:
        subj = 'sub-' + i
        covpath = home + '/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/' + subj + '/timing/'
        cov_Base = pd.read_table(covpath + GLM + '_task-PIT_CS_Baseline.txt',sep='\t', header=None)
        cov_minus = pd.read_table(covpath + GLM + '_task-PIT_CS_CSm.txt',sep='\t', header=None)
        cov_plus = pd.read_table(covpath + GLM + '_task-PIT_CS_CSp.txt',sep='\t', header=None)
    
        dfsubj = np.append(dfsubj, i)
    
        CSp = cov_plus[2]
        df1 = np.append(df1, CSp.mean())
    
    
        Baseline = cov_Base[2]
        df2 = np.append(df2, Baseline.mean())
    
    
        CSm = cov_minus[2] 
        df3 = np.append(df3, CSm.mean())
    
  #%%  
    df01[0] = dfsubj
    df02[0] = dfsubj
    df03[0] = dfsubj

    # mean center BY CONDITION
    df01[1] = df1 - df1.mean()
    df02[1] = df2 - df2.mean()
    df03[1] = df3 - df3.mean()
    
    df01.columns = ['subj', cond]
    df02.columns = ['subj', cond]
    df03.columns = ['subj', cond]

    
    os.chdir(home +'/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/group_covariates')
    df01.to_csv('CSp_' + cond + '_meancent.txt',sep='\t', index=False)
    df02.to_csv('Baseline_' + cond + '_meancent.txt',sep='\t', index=False)
    df03.to_csv('CSm_' + cond + '_meancent.txt',sep='\t', index=False)
    
    print("covariates done")