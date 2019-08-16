
function simGP()
cd('/Users/jlee/OneDrive - University College London/15_SummerSchools/MIND/MINDwizards/SimulationCode/fitting_results')
load('GPrecentsigma_fits.mat')
allpars = vertcat(results.x);
load('../../Data/data.mat')

for subj = 1:41
    data = sub(subj);
    num_trials  = data.nTrials;
    params = allpars(subj,:);

    lambda      = params(1); %
    sigma_f    = params(2); % scale 
    sigma_e    = params(3); % probably fairly low
    tau       = params(4); % noise in response function
    sigma       = params(5); % noise in response function

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
            % transpose it to make each trial a column of the matrix
            X_old = data.bars(1:trial-1,:)'; 
            
            % mean function
            m = K(X,X_old,trial,1:trial-1,lambda,sigma_f,tau) * ...
                inv(K(X_old,X_old,1:trial-1,1:trial-1,lambda,sigma_f,tau) + ...
                sigma_e^2*eye(trial-1)) * y_old;
            
            % covariance matrix 
            %(actually variance, because response follows a univariate gaussian)
            cov = K(X,X,trial,trial,lambda,sigma_f,tau) - ...
                K(X,X_old,trial,1:trial-1,lambda,sigma_f,tau) * ...
                inv(K(X_old,X_old,1:trial-1,1:trial-1,lambda,sigma_f,tau) + ...
                sigma_e^2*eye(trial-1)) * ...
                K(X_old,X,1:trial-1,trial,lambda,sigma_f,tau);
            sigma = sqrt(cov);

        end
        
        mean_est{subj}(trial) = m;
        var_est{subj}(trial)  = sigma.^2;

    end
    writeNPY(mean_est{subj}, sprintf('mn_subj%d.npy', subj))
    writeNPY(var_est{subj}, sprintf('var_subj%d.npy', subj))
    disp('yay')
end

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
