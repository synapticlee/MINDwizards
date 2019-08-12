function [ results ] = fit_model( model, data )
% Fit different models to wizards data

%INPUTS: model to fit, data

%OUTPUT: results structure

if nargin < 2
    load('data.mat');
    data = sub;
end

%% Options
starts = 50;
   
switch model 
    case 'single_LR'
    param(1) = struct('name','lr','lb',0,'ub',1e-6); %set name, lower bound, upper bound
    param(2) = struct('name', 'sigma', 'lb', 5, 'ub', 100);

    case 'attention_weight'
    param(1) = struct('name','lr','lb',0,'ub',1);
    param(2) = struct('name', 'sigma', 'lb', .0001, 'ub', 100);
    param(3) = struct('name','invTemp','lb',0,'ub',100);
end

%% Fit
for subject = 1:length(data)
    switch model 
    case 'single_LR'
        f = @(x) likfun_single_LR(x, data(subject));
    case 'attention_weight'
        f = @(x) likfun_attention_weight(x, data(subject));
    end
    disp(['Fitting subject ' int2str(subject)])
    for start = 1:starts

        %define likelihood function
            
         %set fminunc starting values
         x0 = zeros(1, length(param)); % initialize at zero
            for p = 1:length(param)
                x0(p) = unifrnd(param(p).lb, param(p).ub); %pick random starting values
            end
            
        % find min negative log likelihood = maximum likelihood for each subject
        [x, nloglik] = fmincon(f, x0);
            
        % store min negative log likelihood and associated parameter values
            %if starts == 1 || nloglik < results(subject).nll
              %  num_unchanged = 0; %reset to 0 if likelihood changes
                results(subject, start).nll = nloglik;
                results(subject, start).x = x;
            %end
            results(subject, start).sub = subject;
    end
end
    
    
        
%% Run fmincon
results(subject, starts).model = model;
results(subject, starts).num_params = length(param);
    
end

