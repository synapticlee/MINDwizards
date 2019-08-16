function simulate_exemplar_probabilistic()

%% Simulate exemplar probabilistically
% In this simulation, we assume that agents make predictions by sampling
% similar instances they previously experienced, based on the
% euclidean distance between Xs.

% Specifically, agents:
% 1. Weight trials based on their recency.
% 2. Weight trials based on their similarity (Euclidean distance) to previous trials.
% 3. Average to get new prediction.

%% generative parameters ==================================================
% number of dimensions
D = 5;

% regression coefficients
load('../../Data/data.mat')
betaWeights = sort(sub(1).weights(1,:), 'descend');
clear sub

% generative function for sampling stimuli 
% note stimulus values are between 0 and 100
gX = @() (rand(D,1))*100;

% noise function
nZ = @() 0 * randn(1);

%number of subjects
num_subs = 1000;

%% simulate ===============================================================
% initialize learning algorithm
theta = rand(D,1);

T = 500;

for subject = 1:num_subs
    mem_decay = unifrnd(0, .5);
    similarity_weight = unifrnd(0, 10);
    sigma = unifrnd(5, 10);
    sub(subject).mem_decay = mem_decay;
    sub(subject).similarity_weight = similarity_weight;
    sub(subject).sigma = sigma;
    sub(subject).nTrials = T;
    for trial = 1:T
     
        % sample X for this trial
        X = gX();
    
        %compute prediction
        if trial > 1 
            dist = sqrt(sum((x_store - X).^2)); %get matrix of distances
            dist = dist(1:trial-1);
 
            %weight by similarity weight
            dist_weighted = dist.^-(similarity_weight);
            
            %weight by recency
            recency_weight = [1:trial-1].^mem_decay;
            
            %compute prediction weights
            %recency_weight = recency_weight./sum(recency_weight);
            %dist_weighted = dist_weighted ./sum(dist_weighted);
            pred_weights = (dist_weighted .* recency_weight);
            pred_weights = pred_weights ./(sum(pred_weights));
            
            %compute weighted predictions
            Rhat = sum((pred_weights .* correct_response_store(1:trial-1)));  
            
        else 
            Rhat = 50 + 10*randn(1);
        end
    
        %store Rhats
        Rhat_store(:,trial) = Rhat;
    
        %store X's
        x_store(:,trial) = X;
        sub(subject).bars(trial, :) = X;
    
        %add correct response to store
        correct_response = sum(betaWeights' .* X) + nZ();
        correct_response_store(trial) = correct_response;
        sub(subject).correct_response(trial) = correct_response; 
        
        % compute response
        response = Rhat + sigma * randn(1);
        if response < 0
            response = 0;
        elseif response > 100
            response = 100;
        end
        
        sub(subject).response(trial) = response; 
    
        %store error
        error = response - correct_response;
        error_store(trial) = error;
        sub(subject).error(trial) = error; 
    
    end
end

%% save data
save('../../../simulated_exemplar_probabalistic_new', 'sub')

