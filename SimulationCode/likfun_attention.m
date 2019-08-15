function [ nloglik ] = attention( params, data )

% Parameters
num_trials = data.nTrials;
alpha = params(1);
sigma = params(2);
numDim = 5;


%Initialize matrices with theta and probability estimates
theta_estimates = zeros(num_trials, numDim);
choice_probs =  zeros(num_trials, 1);

%Initialize starting values for theta
theta = .2*ones(numDim,1)';

for trial = 1:num_trials
    response = data.response(trial);
    correct_response = data.correct_response(trial);
    X = data.bars(trial, :);
    
    %compute prediction based on parameters
    Rhat = sum(theta .* X);
    
    %compare prediction based on parameters to actual response
    choice_prob = 1/(sigma*sqrt(2*pi))* exp(-.5*((response - Rhat)/sigma)^2); 

    %update values for next trial
    delta = correct_response - response;
    theta = theta + alpha * delta * X;
    
    %store values and choice probabilities
    theta_estimates(trial, :) = theta;
    choice_probs(trial) = choice_prob;
   
end

%compute negative log likelihood
loglik = sum(log(choice_probs));
nloglik = -1*loglik;

