%same as without sigma except separate noise sigma to sigma_e in (co)variance
function nloglik = likfun_GP_recent_sigma(params, data)

% Parameters
num_trials  = data.nTrials;
lambda      = params(1); % length scale
sigma_f     = params(2); % scale
sigma_e     = params(3); % probably fairly low
tau         = params(4); % decay in the past for the GP "memory"
sigma       = params(5); % noise in response function

choice_probs = zeros(1,num_trials);

for trial = 1:num_trials
    
    % data and response for the current trial
    response = data.response(trial);
    X = data.bars(trial, :)';
        
    % mean function
    if trial == 1
        m = 50;
        
    else
        
        % data and correct responses for all previous trials
        y_old = data.correct_response(1:trial-1);
        y_old = y_old(:); % make y a column vector
        % transpose it to make each trial a column of the matrix
        X_old = data.bars(1:trial-1,:)'; 
        
        % mean function
        m = K(X,X_old,trial,1:trial-1,lambda,sigma_f,tau) * ...
            inv(K(X_old,X_old,1:trial-1,1:trial-1,lambda,sigma_f,tau) + ...
            sigma_e^2*eye(trial-1)) * y_old;
        
        if trial==500
            keyboard
        end
    end
    
    % compare prediction based on parameters to actual response
    choice_probs(trial) = ...
        1/(sigma*sqrt(2*pi))* exp(-.5*((response - m)/sigma)^2); 

end

%compute negative log likelihood
loglik = sum(log(choice_probs));
nloglik = -1*loglik;

end

function [newK,T] = K(X, Y, tX, tY, lambda, sigma_f, tau)
% X: NBars * n1
% tX: length n1
% Y: NBars * n2
% tY: length n2

%XX + YY - 2XY (inner product of matrices row by column)
sqrDist = (sum(X'.^2,2)*ones(1, size(Y,2))) + ...
          (sum(Y'.^2,2)*ones(1, size(X,2)))' - ...
          2*X'*Y; % shape n1*n2
K = sigma_f^2*exp(-sqrDist/(2*lambda^2));

tX = tX(:);
tY = tY(:)';
T = exp(-(abs(repmat(tX,1,length(tY)) - repmat(tY,length(tX), 1)))/tau);

newK = K.*T;

end
