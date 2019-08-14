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

# %% [markdown]
# ### load the data

# %%
dataFolder = 'Data_equalWeights/'
subList = ['1cdzsxek92mz66k_2019-08-10', '9fzhnxu5uzmnbuf_2019-08-10']

# %%
data = pd.DataFrame()
for iSub, sub in enumerate(subList):
    dataSub = pd.read_csv(dataFolder+'preprocessed_data_'+sub+'.csv')
    data = data.append(dataSub)

# %% [markdown]
# ### estimate betas

# %%
import statsmodels.api as sm

window = 20

fig, axes = plt.subplots(len(subList),1,figsize=(20,4*len(subList)),sharex=True,sharey=True)
cols = ['bars'+str(i+1) for i in range(5)]
coef = np.empty((len(subList), data['NTrials'].max()-window, 6))
coef[:] = np.nan
for iSub, sub in enumerate(subList):
    dataSub = data[(data['sub']==iSub+1)].copy().reset_index(drop=True)
    beta = [dataSub.loc[0,'weights'+str(iBar+1)] for iBar in range(5)]
    for i in np.arange(dataSub.loc[0,'NTrials']-window):
        dataWindow = dataSub.iloc[i:i+window]
        X = dataWindow[cols].values
        y = dataWindow['response'].values
        X = sm.add_constant(X)
        mod = sm.OLS(y, X)
        res = mod.fit()
        coef[iSub, i, -1] = res.params[0]/100
        coef[iSub, i, 0:-1] = res.params[1:]
    for iBar in range(5):
        axes[iSub].plot(coef[iSub, :, iBar], color='C'+str(iBar), label='bar'+str(iBar+1)+('*' if beta[iBar]>0 else ''))
        axes[iSub].axhline(y=beta[iBar], linestyle='--', color='k')
#     axes[iSub].set_ylim([0,1])
    axes[iSub].legend(loc=1)
    axes[iSub].set(xlabel='trial',ylabel='beta estimate w/ window='+str(window))

# %% [markdown]
# ### absolute error

# %%
data['absError'] = np.abs(data['correct_response'] - data['response'])

# %%
fig, axes = plt.subplots(len(subList),1,figsize=(20,4*len(subList)),sharex=True,sharey=True)
for iSub, sub in enumerate(subList):
    axes[iSub].plot(data.loc[data['sub']==iSub+1, 'absError'])
    axes[iSub].set(xlabel='trial',ylabel='absolute error')

# %%
