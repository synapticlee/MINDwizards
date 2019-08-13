clear

%% Simulate exemplar
% In this simulation, we assume that agents make predictions by sampling
% the most similar instance they previously experienced, based on the
% euclidean distance between Xs

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

% number of trials back people can remember
trial_mem = 100;


%% simulate ===============================================================
% initialize learning algorithm
theta = rand(D,1);

T = 500;

 for t = 1:T
     
    % sample X for this trial
    X = gX();
    
    %compute prediction
    if t > 1 && t < trial_mem
        dist = sqrt(sum((x_store - X).^2));
        Rhat = correct_response_store(dist == min(dist));
    elseif t > trial_mem
       dist = sqrt(sum((x_store - X).^2));
       Rhat = correct_response_store(dist == min(dist(t-trial_mem:t-1))); 
    else
        Rhat = 50 + 10*randn(1);
    end
    
    %store Rhats
    Rhat_store(:,t) = Rhat;
    
    %store X's
    x_store(:,t) = X;
    
    %add correct response to store
    correct_response = beta' * X + nZ();
    correct_response_store(t) = correct_response;
    
    %store error
    error = Rhat - correct_response;
    error_store(t) = error;
    
 end

 %% Plot errors over time
figure(1); clf;  hold on;
plot(error_store')
xlabel('Trial')
ylabel('Error')

%% Plot regression weights
thetas = regress(Rhat_store', x_store');

figure
bar([thetas(1) beta(1); thetas(2) beta(2); thetas(3) beta(3); thetas(4) beta(4); thetas(5) beta(5)]);
xlabel('Predictor')
ylabel('Weight')
legend('Model Prediction', 'True Weight')



