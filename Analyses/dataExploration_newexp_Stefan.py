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
#     version: 3.7.3
# ---

# %%
# %config InlineBackend.figure_format = "retina" # High-res graphs (rendered irrelevant by svg option below)
# %config InlineBackend.print_figure_kwargs = {"bbox_inches": "tight"} # No extra white space
# %config InlineBackend.figure_format = "svg" # 'png' is default

from IPython.core.debugger import set_trace
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import linregress
import scipy as sp

# %% [markdown]
# ### load the data

# %%
# get the list of subjects
subList = []
dataFolder = '../Data_equalWeights/'
allFileNames = os.listdir(dataFolder)
for fileName in allFileNames:
    if fileName.startswith('wizard_gems_data'):
        subList.append(fileName[17:17+15])

# %%
data = pd.DataFrame()
for iSub, sub in enumerate(subList):
    dataSub = pd.read_csv(dataFolder+'preprocessed_data_'+sub+'_2019-08-10.csv')
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


# %% [markdown] {"trusted": true}
# ### Split people into learners and non-learners
# We'll just do a median split on sum squared error for the subjects in the last 50 trials.

# %%
def extract_subject_coefficients(coefficients, subject):
    """Extracts the coefficients for a given subject, 
    stripping out nan values since not all subjects have 
    the same number of trials.
    coefficients: 3D numpy array -> (subject, trial, param)
    subject: int -> subject number
    """
    x = np.copy(coefficients) # just to be sure we don't end up messing up the original reference
    x = x[subject, : , :]
    x = x[~np.isnan(x).any(axis=1)]
    return x

def get_sum_square_errors(a, b):
    return np.sum((a - b)**2)

def get_beta_weights(data):
    return [data.loc[0,'weights'+str(bar + 1)] for bar in range(5)]

def get_sorted_subject_coefficients(subject_coefficients, subject_data):
    beta_weights = get_beta_weights(subject_data)
    beta_weight_sort_order = np.argsort(beta_weights)
    return subject_coefficients[:, beta_weight_sort_order]

def get_subject_data(subject, data):
    return data[(data['sub']==subject + 1)].copy().reset_index(drop=True)

# test_window = 50 # last trials on which to judge degree of learning
num_subjects = coef.shape[0]
sum_square_errors = np.zeros(num_subjects) # the errors in learning on last trials
avg_sum_square_errors = np.zeros(num_subjects)
for subject in range(num_subjects): 
    subject_data = get_subject_data(subject, data)
    subject_coefficients = extract_subject_coefficients(coef, subject)
    beta_weights = get_beta_weights(subject_data)
    num_trials = subject_coefficients.shape[0]
    all_trials_coefficients = subject_coefficients[:, :-1] # remove constant
    sum_square_errors[subject] = get_sum_square_errors(all_trials_coefficients, beta_weights)
    avg_sum_square_errors[subject] = sum_square_errors[subject] / num_trials
    
learner_threshold = np.median(avg_sum_square_errors)
learner_indices = np.where(avg_sum_square_errors < learner_threshold)[0]
print(learner_indices)


# %%
def plot_subject_coefficients(coefficients, beta_weights):
    fig, axes = plt.subplots(1, 1, figsize=(15, 4))
    cols = ["bars" + str(i + 1) for i in range(5)]
    for bar in range(5):
        axes.plot(
            coefficients[:, bar],
            color="C" + str(bar) if beta_weights[bar] > 0 else "black",
            label="bar" + str(bar + 1) + ("*" if beta_weights[bar] > 0 else ""),
        )
        axes.axhline(y=beta_weights[bar], linestyle="--", color="C" + str(bar))
    axes.set_ylim([0, 1])
    plt.legend()


# Plot subject coefficients in ascending order of error
subject_sort_order = np.argsort(avg_sum_square_errors)
for subject in subject_sort_order:
    subject_data = get_subject_data(subject, data)
    subject_coefficients = extract_subject_coefficients(coef, subject)
    beta_weights = get_beta_weights(subject_data)    
    sorted_subject_coefficients = get_sorted_subject_coefficients(subject_coefficients, subject_data)
#     set_trace()
    # Resort based on the weight levels
    zero_bar_coefficients = sorted_subject_coefficients[:, :2]
    non_zero_bar_coefficients = np.sort(sorted_subject_coefficients[:, 2:])
    sorted_subject_coefficients = np.concatenate((zero_bar_coefficients, non_zero_bar_coefficients), axis=1)
    plot_subject_coefficients(sorted_subject_coefficients, sorted_weights)


# %% [markdown]
# # Plot the average learner and non-learner curves up to the point where they all have trial data

# %%
def get_min_trials(coefficients):
    num_subjects = coefficients.shape[0]
    min_trials = np.inf
    for subject in range(num_subjects):
        subject_coefficients = extract_subject_coefficients(coef, subject)
        num_trials = subject_coefficients.shape[0]
        if min_trials > num_trials:
            min_trials = num_trials
    return min_trials


def get_dataframe_of_coefficients(orig_data, coefficients, num_trials, learner_indices):
    weight_dict = {key: f"weight_{key}" for key in range(6)}
    columns = [
        "subject_number",
        "learner",
        "trial",
        "weight_num",
        "weight",
        "true_weight",
    ]
    index = []
    data = pd.DataFrame(index=index, columns=columns)
    data_template = data.copy()
    num_subjects = coefficients.shape[0]
    frames = []
    for subject in range(num_subjects):
        subject_data = data_template.copy()
        subject_coefficients = extract_subject_coefficients(coef, subject)
        orig_subject_data = get_subject_data(subject, orig_data)
        sorted_subject_coefficients = get_sorted_subject_coefficients(subject_coefficients, orig_subject_data)
        beta_weights = get_beta_weights(orig_subject_data)
        sorted_beta_weights = np.sort(beta_weights)
        if subject in learner_indices:
            learner = True
        else:
            learner = False
        for trial, row in enumerate(sorted_subject_coefficients[:num_trials, :]):
            for weight_num, weight in enumerate(row):
                weight_name = weight_dict[weight_num]
                true_weight = sorted_beta_weights[weight_num] if weight_num < 5 else 0
                new_row = [subject, learner, trial, weight_name, weight, true_weight]
                subject_data = subject_data.append(
                    pd.DataFrame([new_row], index=["e"], columns=subject_data.columns)
                )

        frames.append(subject_data)
    data = pd.concat(frames)
    return data


min_trials = get_min_trials(coef)
data_for_plotting = get_dataframe_of_coefficients(
    data, coef, min_trials, learner_indices
)
data_for_plotting.reset_index(drop=True, inplace=True)
data_for_plotting.shape

# %%
data_for_plotting.head()


# %%
def plot_average_data(data, beta_weights, filename=None):
    """Plots the data for the estimated weights 
    across all trials, along with dashed lines for the 
    constants defined in beta_weights."""
    sns.set(style="ticks", rc={"lines.linewidth": 2.5})
    plt.figure(figsize=(10, 6))
    ax = sns.lineplot(x="trial", y="weight", hue="weight_num", data=data)
    # Draw constant horizontal lines
    for i, beta in enumerate(beta_weights):
        ax.axhline(y=beta, linestyle="--", color="C" + str(i))

    # Legend
    legend_labels = [str(beta) for beta in beta_weights]
    legend_labels.append("constant")

    # move legend outside of plot
    leg = plt.legend(
        bbox_to_anchor=(1.05, 1),
        loc=2,
        borderaxespad=0.0,
        fontsize=12,
        labels=legend_labels,
    )

    # change legend frame color
    leg.get_frame().set_edgecolor("#000000")

    # Change font sizes and labels
    ax.set_ylabel("Weight", fontsize=16)
    ax.set_xlabel("Trial Number", fontsize=16)

    # Set axis limits
    ax.set_ylim([-0.2, 0.8])
    ax.set_xlim([0, data["trial"].max()])

    # Change ticks
    x_tick_step = 50
    plt.xticks(np.arange(0, data["trial"].max() + x_tick_step, x_tick_step))
    ax.tick_params(labelsize=12)

    # Remove top and right borders
    sns.despine()

    # Save figure
    if filename is not None:
        plt.savefig(filename)


sorted_beta_weights = np.sort(beta_weights)
learner_data = data_for_plotting[data_for_plotting["learner"] == 1]
plot_average_data(learner_data, sorted_beta_weights) # filename="learner.svg"

# %%
non_learner_data = data_for_plotting[data_for_plotting["learner"] == 0]
plot_average_data(non_learner_data, beta_weights) #  filename="non-learner.svg"

# %%
