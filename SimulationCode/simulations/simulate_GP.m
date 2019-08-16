function simulate_GP()
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

%number of subjects
num_subs = 1;


%% simulate ===============================================================
% initialize learning algorithm

T = 500;

for subject = 1:num_subs
    
    % model parameters
    lambda     = 500; %unifrnd(10, 100); %
    sigma_f    = 80; %unifrnd(0, 100); % scale
    sigma_e    = 150; %unifrnd(0, 100); % probably fairly low
%     sigma       = unifrnd(5, 10); % noise in response function
    
    sub(subject).lambda = lambda;
    sub(subject).sigma_f = sigma_f;
    sub(subject).sigma_e = sigma_e;
%     sub(subject).sigma = sigma;
    sub(subject).nTrials = T;
    
    for trial = 1:T
        
        % sample X for this trial
        X = gX();
        sub(subject).bars(trial, :) = X;
        correct_response = betaWeights * X;
        sub(subject).correct_response(trial) = correct_response;
        
        % compute prediction
        if trial == 1
            
            m = 50;
            response = m + sigma_e * randn();
            
        else
            
            % data and correct responses for all previous trials
            y_old = sub(subject).correct_response(1:trial-1);
            y_old = y_old(:); % make y a column vector
            X_old = sub(subject).bars(1:trial-1,:)'; % transpose it to make each trial a column of the matrix
            
%             % mean-center the data
%             X_old = X_old - repmat(mean(X_old,2),1,size(X_old,2));
            
            % mean function
            m = K(X,X_old,lambda,sigma_f) * inv(K(X_old,X_old,lambda,sigma_f) + sigma_e^2*eye(trial-1)) * y_old;
            
            % covariance matrix (actually variance, because response follows a univariate gaussian)
            cov = K(X,X,lambda,sigma_f) - ...
                K(X,X_old,lambda,sigma_f) * ...
                inv(K(X_old,X_old,lambda,sigma_f) + sigma_e^2*eye(trial-1)) * ...
                K(X_old,X,lambda,sigma_f);
            
            response = m + sqrt(cov) * randn();
            
        end
        
        if response > 100
            response = 100;
        end
        if response < 10
            response = 0;
        end
        
        sub(subject).response(trial) = response;
        
    end
end


%% save data
save('simulated_GP', 'sub')

end

function K = K(X, Y, lambda, sigma_f)
% X: NBars * 1
% Y: NBars * (trial-1)

%XX + YY - 2XY (inner product of matrices row by column)
% sqrDist = sum(X.^2, 1)' * ones(1, size(Y,2)) + ...
%           ones(size(X,2), 1) * sum(Y.^2, 1) - ...
%           2*X'*Y;
sqrDist = (sum(X'.^2,2)*ones(1, size(Y,2))) + ...
          (sum(Y'.^2,2)*ones(1, size(X,2)))' - ...
          2*X'*Y;

K = sigma_f^2*exp(-sqrDist/(2*lambda^2));

end

