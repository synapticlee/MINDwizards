%% generative parameters ==================================================

% number of dimensions
D = 5;

% regression coefficients
beta = [.55; .25; .12; .06; .02];

% generative function for sampling stimuli 
% note stimulus values are between 0 and 100
gX = @() (rand(D,1))*100;

% noise function
nZ = @() 0 * randn(1);

%number of subjects
num_subs = 10000;


%% simulate ===============================================================
% initialize learning algorithm
theta = rand(D,1);

T = 500;

for subject = 1:num_subs
    alpha = unifrnd(0, 1e-4);
    sigma = unifrnd(5, 10);
    sub(subject).alpha = alpha;
    sub(subject).sigma = sigma;
    sub(subject).nTrials = T;
    for trial = 1:T
   
        %theta_store(:,t, alpha_vals, sigma_vals) = theta;
    
    % sample X for this trial
    X = gX();
    sub(subject).bars(trial, :) = X;
    correct_response = beta' * X + nZ();
    sub(subject).correct_response(trial) = correct_response; 
    
     % compute prediction
     Rhat = theta' * X;
    
     % compute response
     response = Rhat + sigma * randn(1);
     if response < 0
         response = 0;
     elseif response > 100
         response = 100;
     end
        
     sub(subject).response(trial) = response; 
    
     %  compute prediction error
     delta = correct_response - response;
     sub(subject).error(trial) = delta; 
    
     % update
     theta = theta + alpha * delta * X;
    
    end
end


%% save data
save('../../simulated_1LR', 'sub')

