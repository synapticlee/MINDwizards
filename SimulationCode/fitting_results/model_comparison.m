%% Compare AIC and BIC values %%


%Load results
load('single_LR_fits.mat');
singleLR = results;

load('exemplar_weights_fits.mat')
exemplar = results;

load('attention_fits');
attention = results;

load('GPsigma_fits');
GP = results;

load('GPrecentsigma_fits');
GP2 = results;

load('GPpertrial_fits');
GP3 = results;

load('lm_results');
lm = results;

load('serial_hypothesis_constant_results.mat');
serial = results;

%load('serial_hypothesis_adapt_results.mat');
%serial2 = results;


%% AIC comparison
% Find best-fitting model for each subject
for sub = 1:length(singleLR)
    AIC(sub, 1) = singleLR(sub).AIC(1);
    AIC(sub, 3) = exemplar(sub).AIC(1);
    AIC(sub, 2) = attention(sub).AIC(1);
    AIC(sub, 6) = GP(sub).AIC(1);
    AIC(sub, 5) = GP2(sub).AIC(1);
    AIC(sub, 4) = GP3(sub).AIC(1);
    AIC(sub, 7) = lm(sub).AIC(1);
    AIC(sub, 8) = serial(sub).AIC(1);
    %AIC(sub, 9) = serial2(sub).AIC(1);
end

%find minimum AIC
[AIC_vals, best_model_AIC] = min(AIC, [], 2);
    
%% BIC Comparison
for sub = 1:length(singleLR)
    BIC(sub, 1) = singleLR(sub).BIC(1);
    BIC(sub, 3) = exemplar(sub).BIC(1);
    BIC(sub, 2) = attention(sub).BIC(1);
    BIC(sub, 6) = GP(sub).BIC(1);
    BIC(sub, 5) = GP2(sub).BIC(1);
    BIC(sub, 4) = GP3(sub).BIC(1);
    BIC(sub, 7) = lm(sub).BIC(1);
    BIC(sub, 8) = serial(sub).BIC(1);
    %BIC(sub, 9) = serial2(sub).BIC(1);
end

%find minimum BIC
[BIC_vals, best_model_BIC] = min(BIC, [], 2);

%% Make histogram of model fits

AIC_subtraction = AIC - AIC(:, 3);
BIC_subtraction = BIC - BIC(:, 3);


figure;
subplot(2,2,1)
%boxplot(AIC_subtraction);
hold on
bar(mean(AIC_subtraction));
xticks([1:8])
xticklabels({'RL','Attention','Exemplar','GP', 'GP sigma', 'GP w/ recency','lm', 'serial'})
xtickangle(50);
title("AIC relative to best model")

subplot(2,2,2)
bar(mean(BIC_subtraction));
xticks([1:8])
xticklabels({'RL','Attention','Exemplar','GP', 'GP sigma', 'GP w/ recency','lm', 'serial'})
xtickangle(50);
title("BIC relative to best model")

subplot(2,2,3);
histogram(best_model_AIC, 1:9);
xticklabels({'RL','Attention','Exemplar','GP', 'GP sigma', 'GP w/ recency','lm', 'serial'})
xtickangle(50);
xticks([1.5:1:8.5])
title("Distribution of minimum AICs")

subplot(2,2,4);
histogram(best_model_BIC, 1:9);
xticklabels({'RL','Attention','Exemplar','GP', 'GP sigma', 'GP w/ recency','lm', 'serial'})
xticks([1.5:1:8.5])
xtickangle(50);
title("Distribution of minimum BICs")





