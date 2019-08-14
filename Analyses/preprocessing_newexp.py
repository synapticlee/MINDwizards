# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: all
#     notebook_metadata_filter: all
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.2'
#       jupytext_version: 1.2.1
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
#   language_info:
#     codemirror_mode:
#       name: ipython
#       version: 3
#     file_extension: .py
#     mimetype: text/x-python
#     name: python
#     nbconvert_exporter: python
#     pygments_lexer: ipython3
#     version: 3.7.2
# ---

# %%
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import linregress
import scipy as sp

# %%
subList = ['1cdzsxek92mz66k_2019-08-10', '9fzhnxu5uzmnbuf_2019-08-10']

# %%
colNames = ['sub','NTrials','iTrial','correct_response', 'response'] + ['bars'+str(i) for i in np.arange(5)+1] + ['weights'+str(i) for i in np.arange(5)+1] + ['condition', 'RT']

# %%
data = pd.DataFrame()

for iSub, sub in enumerate(subList):
    dataSub = pd.read_csv('wizard_gems_data_'+sub+'.csv')
    dataSub = dataSub[dataSub['trial_type'] == 'wizard-gem-trial'].copy().reset_index(drop=True)
    dataSub['sub'] = iSub+1
    dataSub['NTrials']= dataSub.shape[0]
    dataSub['iTrial']= np.arange(dataSub.shape[0])+1
    dataSub['correct_response'] = dataSub['correct_answer']
    dataSub['RT'] = dataSub['rt']
    dataSub['condition'] = 1
    
    for iRow in range(dataSub.shape[0]):
        gem_values_str = dataSub.loc[iRow, 'gem_values'][1:-1]
        locComma = [-1]
        for i, char in enumerate(gem_values_str):
            if char == ',':
                locComma.append(i)
        locComma.append(len(gem_values_str))
        for iBar in range(5):
            dataSub.loc[iRow, 'bars'+str(iBar+1)] = int(gem_values_str[locComma[iBar]+1:locComma[iBar+1]])
            
        gem_weights_str = dataSub.loc[iRow, 'gem_weights'][1:-1]
        locComma = [-1]
        for i, char in enumerate(gem_weights_str):
            if char == ',':
                locComma.append(i)
        locComma.append(len(gem_weights_str))
        for iBar in range(5):
            dataSub.loc[iRow, 'weights'+str(iBar+1)] = float(gem_weights_str[locComma[iBar]+1:locComma[iBar+1]])
    
    dataSub = dataSub[colNames]
    dataSub.to_csv('preprocessed_data_'+sub+'.csv',index=None)
    
    data = data.append(dataSub)

# %%
data.to_csv('preprocessed_data_2019-08-10.csv',index=None)
