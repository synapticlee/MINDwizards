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
#     display_name: Python 3 (openpose)
#     language: python
#     name: openpose
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
import scipy as sp

# %% [markdown]
# # AIC/BIC

# %% [markdown]
# ## Load data

# %%
aic = np.load("AIC.npy")
bic = np.load("BIC.npy")
num_subjects, num_models = aic.shape
best_model = 2 # 0-indexing

# %% [markdown]
# ## Transform into dataframe for seaborn

# %%
columns = ["subject", "metric", "model", "amount"]
index = []
data = pd.DataFrame(index=index, columns=columns)

metric_dict = {
    "aic": aic,
    "bic": bic
}

for metric, vals in metric_dict.items():
    for subject, row in enumerate(vals):        
        for model, amount in enumerate(row):
            model = f"model_{model}"
            data_row = [subject, metric, model, amount]
            data = data.append(pd.DataFrame([data_row],index=['e'],columns=data.columns))

data.head()

# %% [markdown]
# # Subtract average of best model from all vals

# %%
zero_centered_data = data.copy()
best_model_data = data[data["model"] == "model_2"]
frames = []
for metric, _ in metric_dict.items():
    best_model_metric_data = best_model_data[best_model_data["metric"] == metric]
    average_to_subtract = best_model_metric_data["amount"].mean()
    metric_data = zero_centered_data[zero_centered_data["metric"] == metric].copy()
    metric_data["zero_centered_amount"] = metric_data["amount"] - average_to_subtract
    frames.append(metric_data)

zero_centered_data = pd.concat(frames)
zero_centered_data.head()

# %%
for metric, vals in metric_dict.items():
    these_data = zero_centered_data[zero_centered_data["metric"] == metric]
    plt.figure(figsize=(10, 10))
    ax = sns.violinplot(
        x="model", y="zero_centered_amount", data=these_data, inner=None
    )
    ax = sns.swarmplot(
        x="model",
        y="zero_centered_amount",
        data=these_data,
        color="white",
        edgecolor="gray",
    )
    plt.savefig(f"{metric}_beeswarm_violin.svg")
    plt.show()
