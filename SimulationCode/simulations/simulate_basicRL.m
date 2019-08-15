
%% generative parameters ==================================================

% number of dimensions
D = 2;

% regression coefficients
beta = rand(D,1);
beta = beta / sum(beta);

% generative function for sampling stimuli 
% note stimulus values are between -1 and +1
gX = @() (rand(D,1)-0.5)*2;

% noise function
nZ = @() 0 * randn(1);


%% simulate ===============================================================
% initialize learning algorithm
theta = rand(D,1);

T = 1000;
alpha = 0.1;

for t = 1:T

    theta_store(:,t) = theta;

    % sample X for this trial
    X = gX();
    R = beta' * X + nZ();

    % compute prediction
    Rhat = theta' * X;

    %  compute prediction error
    delta = R - Rhat;

    % update
    theta = theta + alpha * delta * X;

end


figure(1); clf;  hold on;
plot(theta_store')
for i = 1:D
    plot([0 T], [1 1]*beta(i), 'k--')
end
ylim([0 1])
xlabel('time step')
ylabel('regression parameter, \theta')


figure(2); clf; hold on;
plot(theta_store(1,:), theta_store(2,:))
xlim([0 1]); ylim([0 1])
plot(theta_store(1,1), theta_store(2,1), 'r.')
plot(beta(1), beta(2), 'r*')
xlabel('weight 1')
ylabel('weight 2')
