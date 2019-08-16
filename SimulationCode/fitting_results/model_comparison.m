%% Compare AIC and BIC values %%


%Load results
load('single_LR_fits.mat');
singleLR = results;

load('exemplar_weights_fits.mat')
exemplar = results;

load('attention_fits');
attention = results;

%% AIC comparison
% Find best-fitting model for each subject
for sub = 1:length(singleLR)
    AIC(sub, 1) = singleLR(sub).AIC(1);
    AIC(sub, 2) = exemplar(sub).AIC(1);
    AIC(sub, 3) = attention(sub).AIC(1);
end

%find minimum AIC
[val, best_model_AIC] = min(AIC, [], 2);
    
%% BIC Comparison
for sub = 1:length(singleLR)
    BIC(sub, 1) = singleLR(sub).AIC(1);
    BIC(sub, 2) = exemplar(sub).AIC(1);
    BIC(sub, 3) = attention(sub).AIC(1);
end

%find minimum BIC
[val, best_model_BIC] = min(BIC, [], 2);

