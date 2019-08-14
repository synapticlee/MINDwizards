function [ nloglik ] = likfun_exemplar_probabilistic( params, data )

% Parameters
num_trials = data.nTrials;
mem_decay = params(1);
similarity_weight = params(2);
sigma = params(3);
numDim = 5;

%Initialize matrices with theta and probability estimates
choice_probs =  zeros(num_trials, 1);


for trial = 1:num_trials
    response = data.response(trial);
    correct_response = data.correct_response(trial);
    X = data.bars(trial, :); 
    
    
    if trial > 1
        %get matrix of distances
        dist = sqrt(sum((x_store - X').^2));
        dist = dist(1:trial-1); 
    
        %compute weights
        dist_weighted = dist.^-(similarity_weight);
        recency_weight = [1:trial-1].^mem_decay;
        pred_weights = (dist_weighted .* recency_weight);
        pred_weights = pred_weights ./(sum(pred_weights));
    
        %compute prediction based on parameters
        Rhat = sum((pred_weights .* correct_response_store(1:trial-1)));  
    
        %compare prediction based on parameters to actual response
        choice_prob = 1/(sigma*sqrt(2*pi))* exp(-.5*((response - Rhat)/sigma)^2); 
    
    else
        choice_prob = 1;
    end
    
    %store X's
    x_store(:, trial) = X;
    
    %add correct response to store
    betaWeights = data.weights;
    correct_response_store(trial) = correct_response;
    
    %store choice probabilities
    choice_probs(trial) = choice_prob;
   
end

%compute negative log likelihood
loglik = sum(log(choice_probs));
nloglik = -1*loglik;

end

