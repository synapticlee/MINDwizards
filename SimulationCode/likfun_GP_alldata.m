function negLL = likfun_GP_alldata(params, data)

% Parameters
num_trials  = data.nTrials;
lambda      = params(1); %
sigma2_f    = params(2); %scale 
sigma2_e    = params(3); %probably fairly low

% the data and responses
y = data.response(1:num_trials);
y = y(:); % make y a column vector
X = data.bars(1:num_trials,:)'; % transpose it to make each trial a column of the matrix

% mean-center the data
X = X - repmat(mean(X,2),1,size(X,2));

% log marginal likelihood
Ky = K(X,X,lambda,sigma2_f) + sigma2_e*eye(num_trials); %plus standard epsilon noise

logDetKy = 2*sum(log(diag(chol(Ky)))); %this avoids overflow to infinity when taking det
negLL = -(-1/2 * y'*inv(Ky)*y - 1/2 * logDetKy - num_trials/2*log(2*pi));

end

function K = K(X, Y, lambda, sigma2_f)
% X are a matrix with columns as the bar heights for one trial

%XX + YY - 2XY (inner product of matrices row by column)
sqrDist = (sum(X'.^2,2)*ones(1, size(Y,2))) + ...
          (sum(Y'.^2,2)*ones(1, size(X,2)))' - ...
          2*X'*Y;

K = sigma2_f*exp(-sqrDist/(2*lambda^2));

end
