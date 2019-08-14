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
dataFolder = 'WizardGemsData'
files = os.listdir(dataFolder)

# %%
colNames = ['correct_response', 'response'] + ['bars'+str(i) for i in np.arange(5)+1] + ['weights'+str(i) for i in np.arange(5)+1] + ['condition', 'RT']

# %%
dataList = []
data = pd.DataFrame()
for file in files:
    dataSub = pd.read_csv(dataFolder + '/' + file, usecols=[0,1,4,5,6,7,8,9,10,11,12,13,14,15], names=colNames, skiprows=[0])
    dataSub.insert(loc=0, column='sub', value=int(''.join([file[i] for i in np.arange(3,file.find('_'))])))
    dataSub.insert(loc=1, column='NTrials', value=dataSub.shape[0])
    dataSub.insert(loc=2, column='iTrial', value=np.arange(dataSub.shape[0])+1)
    dataSub.insert(loc=3, column='block', value=np.ceil(dataSub['iTrial'].values/10))
    dataSub.insert(loc=3, column='NBlocks', value=dataSub['block'].max())
    dataList.append(dataSub)
    data = data.append(dataSub)

# %%
data.head(30)

# %%
subList = data['sub'].unique()
NSub = len(subList)

# %% [markdown]
# ### Absolute error over time

# %%
data['absError'] = np.abs(data['correct_response'] - data['response'])

# %%
learningCurves = np.empty((NSub, data['NTrials'].max()))
learningCurves[:] = np.nan
plt.subplots(1,1,figsize=(20,4))
for iSub, sub in enumerate(subList):
    dataSub = data[data['sub']==sub]
    learningCurves[iSub,np.arange(dataSub.loc[0,'NTrials'])] = dataSub['absError'].values
plt.plot(np.mean(learningCurves,axis=0))
plt.ylabel('absolute error (average across participants)')
plt.xlabel('trial')

# %%
fig, axes = plt.subplots(len(subList),1,figsize=(20,4*len(subList)))
for iSub, sub in enumerate(subList):
    axes[iSub].plot(data.loc[data['sub']==sub, 'absError'])

# %%
fig, ax = plt.subplots(1,1,figsize=(20,4))
data.groupby(['sub','condition']).mean()['absError'].unstack().plot(kind='bar', ax=ax)
print(data.groupby(['sub','condition']).mean()['absError'].groupby('condition').mean())
ax.set_ylabel('absolute error')

# %%
datatmp = data.copy()
datatmp['half'] = 1 * (datatmp['iTrial']<=datatmp['NTrials']/2) + 2 * (datatmp['iTrial']>datatmp['NTrials']/2)
fig, ax = plt.subplots(1,1,figsize=(20,4))
datatmp.groupby(['sub','half']).mean()['absError'].unstack().plot(kind='bar', ax=ax)
ax.set_ylabel('absolute error')
print(datatmp.groupby(['sub','half']).mean()['absError'].groupby('half').mean())

# %% [markdown]
# ### Test whether people (percentage of participants) are using the information of each of the bars

# %% [markdown]
# #### try correlation with sliding windows

# %%
for window in [10,20,30,50,100]:
    cols = ['bars'+str(i+1) for i in range(5)]
    pMat = np.empty((NSub, data['NTrials'].max()-window, 5))
    pMat[:] = np.nan
    for iSub, sub in enumerate(subList):
        dataSub = data[(data['sub']==sub)].copy().reset_index(drop=True)
        for i in np.arange(dataSub.loc[0,'NTrials']-window):
            dataWindow = dataSub.iloc[i:i+window]
            for iBar in range(5):
                r, p = sp.stats.pearsonr(dataWindow['response'], dataWindow['bars'+str(iBar+1)])
                pMat[iSub, i, iBar] = p
    fig, ax = plt.subplots(1,1,figsize=(8,4))
    for iBar in range(5):
        ax.plot(np.nanmean(pMat[:,range(data['NTrials'].min()),iBar]<0.05,axis=0), label=iBar+1)
    ax.legend()
    ax.set_ylim([0,1])
    ax.set_title('window='+str(window))

# %% [markdown]
# #### try linear regression (with a constant term) with sliding windows

# %%
import statsmodels.api as sm

for window in [10,20,30,50,100]:
    cols = ['bars'+str(i+1) for i in range(5)]
    pMat = np.empty((NSub, data['NTrials'].max()-window, 5))
    pMat[:] = np.nan
#     inCIMat = np.empty((NSub, data['NTrials'].max()-window, 5))
#     inCIMat[:] = np.nan
    for iSub, sub in enumerate(subList):
        dataSub = data[(data['sub']==sub)].copy().reset_index(drop=True)
        for i in np.arange(dataSub.loc[0,'NTrials']-window):
            dataWindow = dataSub.iloc[i:i+window]
            X = dataWindow[cols].values
            y = dataWindow['response'].values
            X = sm.add_constant(X)
            mod = sm.OLS(y, X)
            res = mod.fit()
            pMat[iSub, i, :] = res.pvalues[1:]
#             trueBeta = dataSub.loc[0,'weights'+str(iBar+1)]
#             inCIMat[iSub, i, iBar] = (res.conf_int().loc['bars'+str(iBar+1),1] > trueBeta) & (res.conf_int().loc['bars'+str(iBar+1),0] < trueBeta)
    fig, ax = plt.subplots(1,1,figsize=(8,4))
    for iBar in range(5):
        ax.plot(np.nanmean(pMat[:,range(data['NTrials'].min()),iBar]<0.05,axis=0), label=iBar+1)
    ax.legend()
    ax.set_ylim([0,1])
    ax.set_title('window='+str(window))

# %% [markdown]
# #### try correlation with every few blocks

# %%
nTrialsPerBlock = 10
for nBlocks in [1,2,3,5,10]:
    sliceSize = nBlocks*nTrialsPerBlock
    cols = ['bars'+str(i+1) for i in range(5)]
    pMat = np.empty((NSub, int(np.ceil(data['NTrials'].max()/sliceSize)), 5))
    pMat[:] = np.nan
    for iSub, sub in enumerate(subList):
        dataSub = data[(data['sub']==sub)].copy().reset_index(drop=True)
        for i in range(int(np.ceil(dataSub.loc[0,'NTrials']/sliceSize)-1)):
            dataSlice = dataSub.iloc[int(i*sliceSize):int(np.min([(i+1)*sliceSize,dataSub.shape[0]]))]
            for iBar in range(5):
                r, p = sp.stats.pearsonr(dataSlice['response'], dataSlice['bars'+str(iBar+1)])
                pMat[iSub, i, iBar] = p
    fig, ax = plt.subplots(1,1,figsize=(15,4))
    for iBar in range(5):
        ax.plot(np.nanmean(pMat[:,range(int(np.ceil(data['NTrials'].min()/sliceSize))),iBar]<0.05,axis=0), label=iBar+1)
    ax.legend()
    ax.set_ylim([0,1])
    ax.set_title('slice size: ' + str(nBlocks) + ' blocks')

# %% [markdown]
# #### try linear regression (with a constant term) with every few blocks

# %%
import statsmodels.api as sm

nTrialsPerBlock = 10
for nBlocks in [1,2,3,5,10]:
    sliceSize = nBlocks*nTrialsPerBlock
    cols = ['bars'+str(i+1) for i in range(5)]
    pMat = np.empty((NSub, int(np.ceil(data['NTrials'].max()/sliceSize)), 5))
    pMat[:] = np.nan
    for iSub, sub in enumerate(subList):
        dataSub = data[(data['sub']==sub)].copy().reset_index(drop=True)
        for i in range(int(np.ceil(dataSub.loc[0,'NTrials']/sliceSize)-1)):
            dataSlice = dataSub.iloc[int(i*sliceSize):int(np.min([(i+1)*sliceSize,dataSub.shape[0]]))]
            X = dataSlice[cols].values
            y = dataSlice['response'].values
            X = sm.add_constant(X)
            mod = sm.OLS(y, X)
            res = mod.fit()
            pMat[iSub, i, :] = res.pvalues[1:]
    fig, ax = plt.subplots(1,1,figsize=(15,4))
    for iBar in range(5):
        ax.plot(np.nanmean(pMat[:,range(int(np.ceil(data['NTrials'].min()/sliceSize))),iBar]<0.05,axis=0), label=iBar+1)
    ax.legend()
    ax.set_ylim([0,1])
    ax.set_title('slice size: ' + str(nBlocks) + ' blocks')

# %%
# %load_ext rpy2.ipython

# %% {"magic_args": "-i df -o resid -o fitted", "language": "R"}

# %% [markdown]
# ### Estimate the coefficients people use

# %% [markdown]
# #### with sliding windows

# %%
beta = [0.12, 0.02, 0.55, 0.25, 0.06]

# %%
import statsmodels.api as sm

window = 50

fig, axes = plt.subplots(len(subList),1,figsize=(20,4*len(subList)))
cols = ['bars'+str(i+1) for i in range(5)]
coef = np.empty((NSub, data['NTrials'].max()-window, 6))
coef[:] = np.nan
for iSub, sub in enumerate(subList):
    dataSub = data[(data['sub']==sub)].copy().reset_index(drop=True)
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
        axes[iSub].plot(coef[iSub, :, iBar], color='C'+str(iBar))
        axes[iSub].axhline(y=beta[iBar], linestyle='--', color='C'+str(iBar))
    axes[iSub].set_ylim([0,1])

# %% [markdown]
# ### Early learning trials

# %%
