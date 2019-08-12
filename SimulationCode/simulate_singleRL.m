clear

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
    sigma = unifrnd(5, 100);
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
     sub(subject).response(trial) = response; 
    
     %  compute prediction error
     delta = correct_response - response;
     sub(subject).error(trial) = delta; 
    
     % update
     theta = theta + alpha * delta * X;
    
    end
end


%% save data
save('simulated_1LR', 'sub')

%% Plot
% figure(1); clf;  hold on;
% plot(theta_store')
% for i = 1:D
%     plot([0 T], [1 1]*beta(i), 'k--')
% end
% ylim([0 1])
% xlabel('time step')
% ylabel('regression parameter, \theta')
% 
% 
% figure(2); clf; hold on;
% plot(theta_store(1,:), theta_store(2,:))
% xlim([0 1]); ylim([0 1])
% plot(theta_store(1,1), theta_store(2,1), 'r.')
% plot(beta(1), beta(2), 'r*')
% xlabel('weight 1')
% ylabel('weight 2')
