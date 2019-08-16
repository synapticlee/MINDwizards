function nloglik = likfun_GP(params, data)

% Parameters
num_trials  = data.nTrials;
lambda      = params(1); %
sigma_f    = params(2); % scale 
sigma_e    = params(3); % probably fairly low
% sigma       = params(4); % noise in response function

choice_probs = zeros(1,num_trials);

for trial = 1:num_trials
    
    % data and response for the current trial
    response = data.response(trial);
    X = data.bars(trial, :)';
        
    % mean function
    if trial == 1
        m = 50;
        sigma = sigma_e;
        
    else
        
        % data and correct responses for all previous trials
        y_old = data.correct_response(1:trial-1);
        y_old = y_old(:); % make y a column vector
        X_old = data.bars(1:trial-1,:)'; % transpose it to make each trial a column of the matrix
        
%         % mean-center the data
%         X_old = X_old - repmat(mean(X_old,2),1,size(X_old,2));
        
        % mean function
        m = K(X,X_old,lambda,sigma_f) * inv(K(X_old,X_old,lambda,sigma_f) + sigma_e^2*eye(trial-1)) * y_old;
        
        % covariance matrix (actually variance, because response follows a univariate gaussian)
        cov = K(X,X,lambda,sigma_f) - ...
            K(X,X_old,lambda,sigma_f) * ...
            inv(K(X_old,X_old,lambda,sigma_f) + sigma_e^2*eye(trial-1)) * ...
            K(X_old,X,lambda,sigma_f);
        sigma = sqrt(cov);
    end
    
    % compare prediction based on parameters to actual response
    choice_probs(trial) = 1/(sigma*sqrt(2*pi))* exp(-.5*((response - m)/sigma)^2); 
    
end

%compute negative log likelihood
loglik = sum(log(choice_probs));
nloglik = -1*loglik;

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
