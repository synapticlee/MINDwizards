function log_marginal_likelihood = likfun_GP_alldata(params, data)

% Parameters
num_trials = data.nTrials;
lambda = params(1);
sigma2_f = params(2);
sigma2_e = params(3);

% the data and responses
y = data.response(1:num_trials);
y = y(:); % make y a column vector
X = data.bars(1:num_trials,:)'; % transpose it to make each trial a column of the matrix

% mean-center the data
X = X - repmat(mean(X,2),1,size(X,2));

% log marginal likelihood
Ky = K(X,X,lambda,sigma2_f) + sigma2_e*eye(num_trials);
log_marginal_likelihood = -1/2 * y'*inv(Ky)*y - 1/2 * log(det(Ky)) - num_trials/2*log(2*pi);

end

function K = K(X1, X2, lambda, sigma2_f)
% X are a matrix with columns as the bar heights for one trial
K = sigma2_f*exp(-(X1-X2)'*(X1-X2)/(2*lambda^2));
end

function k = RBFkernel(x,xprime,lambda,sigma_f)
% x and xprime are column vectors
k = sigma_f^2*exp(-(x-xprime)'*(x-xprime)/(2*lambda^2));
end