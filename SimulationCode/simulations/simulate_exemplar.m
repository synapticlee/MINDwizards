function simulate_exemplar()

%% Simulate exemplar
% In this simulation, we assume that agents make predictions by sampling
% the most similar instance they previously experienced, based on the
% euclidean distance between Xs

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
    trial_mem = round(unifrnd(1, 499)); % number of trials back people can remember
    sigma = unifrnd(2, 10);
    sub(subject).trial_mem = trial_mem;
    sub(subject).sigma = sigma;
    sub(subject).nTrials = T;
    for trial = 1:T
     
        % sample X for this trial
        X = gX();
    
        %compute prediction
        if trial > 1 && trial < trial_mem
            dist = sqrt(sum((x_store - X).^2));
            Rhat = correct_response_store(dist == min(dist));
            reference_trial = find(Rhat == correct_response_store);
        elseif trial > trial_mem
            dist = sqrt(sum((x_store - X).^2));
            Rhat = correct_response_store(dist == min(dist(trial-trial_mem:trial-1))); 
            reference_trial = find(Rhat == correct_response_store);
        else
            Rhat = 50 + 10*randn(1);
            reference_trial = 0;
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
        sub(subject).reference_trial(trial) = reference_trial;
        
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
save('../../../simulated_exemplar_highTrialMem_withRefTrials', 'sub')

 %% Plot errors over time
% figure(1); clf;  hold on;
% plot(error_store')
% xlabel('Trial')
% ylabel('Error')
% 
% %% Plot regression weights
% thetas = regress(Rhat_store', x_store');
% 
% figure
% bar([thetas(1) beta(1); thetas(2) beta(2); thetas(3) beta(3); thetas(4) beta(4); thetas(5) beta(5)]);
% xlabel('Predictor')
% ylabel('Weight')
% legend('Model Prediction', 'True Weight')

end


