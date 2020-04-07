

#!/usr/bin/env python
# coding: utf-8


# data analysis and wrangling
import pandas as pd
from scipy.stats import linregress



#declare variables
s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")

df = pd.DataFrame()

for i in s:
    subj = 'sub-' + i
    # save filepath to variable for easier access
    corrpath = '/home/cisa/REWOD/DATA/STUDY/CLEAN/' + subj + '/func/'

    # read the data and store data in DataFrame
    corr_data = pd.read_table(corrpath + 'corr_task-hedonic.txt',sep='\t', header=None)
    df = df.append(corr_data, ignore_index=True)

corr = df[0].corr(df[1])
print('r=', corr)
result = linregress(df[0], df[1])
print('pvalue =', round(result.pvalue, 10))
