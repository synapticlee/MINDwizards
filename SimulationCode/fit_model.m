function [ results ] = fit_model( model, results_filename, data )
% Fit different models to wizards data

%INPUTS: model to fit, results file name, data

%OUTPUT: results structure

if nargin < 3
    load('../Data/data.mat');
    data = sub;
end

%% Options
starts = 1;
   
%% Fit
for subject = 1:length(data)
    disp(['Fitting subject ' int2str(subject)])
    for start = 1:starts

        %define likelihood function
            switch model 
                case 'single_LR'
                param(1) = struct('name','lr','lb',0,'ub',1e-6); %set name, lower bound, upper bound
                param(2) = struct('name', 'sigma', 'lb', 5, 'ub', 100);
                f = @(x) likfun_single_LR(x, data(subject));
          
                case 'attention'
                param(1) = struct('name','lr','lb',0,'ub',1e-6);
                param(2) = struct('name', 'sigma', 'lb', 5, 'ub', 100);
                param(3) = struct('name','invTemp','lb',.5,'ub',10);
                f = @(x) likfun_attention(x, data(subject));
                
                case 'exemplar_probabilistic'
                param(1) = struct('name','mem_decay','lb',0,'ub',10);
                param(2) = struct('name', 'similarity_weight', 'lb', 0, 'ub', 10);
                param(3) = struct('name','sigma','lb', 5,'ub', 100);
                f = @(x) likfun_exemplar_probabilistic(x, data(subject));
                
                case 'gp_pertrial'
                param(1) = struct('name', 'lambda', 'lb', 0,'ub', inf, 'lbs', 25, 'ubs', 100); % length scale
                param(2) = struct('name', 'sigma_f', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % RBF variance
                param(3) = struct('name', 'sigma_e', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % noise in the generative model
%                 param(4) = struct('name', 'sigma', 'lb', 5, 'ub', 10); % response noise
                f = @(x) likfun_GP(x, data(subject));

                case 'gp_recent'
                param(1) = struct('name', 'lambda', 'lb', 0,'ub', inf, 'lbs', 25, 'ubs', 100); % length scale
                param(2) = struct('name', 'sigma_f', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % RBF variance
                param(3) = struct('name', 'sigma_e', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % noise in the generative model
                param(4) = struct('name', 'tau', 'lb', 0, 'ub', inf, 'lbs', 0, 'ubs', 500); % timescale of "memory" in past
%                 param(4) = struct('name', 'sigma', 'lb', 5, 'ub', 10); % response noise
                f = @(x) likfun_GP_recent(x, data(subject));
                
                case 'gp_sigma'
                param(1) = struct('name', 'lambda', 'lb', 0,'ub', inf, 'lbs', 25, 'ubs', 100); % length scale
                param(2) = struct('name', 'sigma_f', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % RBF variance
                param(3) = struct('name', 'sigma_e', 'lb', 0, 'ub', inf, 'lbs', 0, 'ubs', 10); % noise in the generative model
                param(4) = struct('name', 'sigma', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % response noise
                f = @(x) likfun_GP_sigma(x, data(subject));
                case 'gp_recent_sigma'
                param(1) = struct('name', 'lambda', 'lb', 0,'ub', inf, 'lbs', 25, 'ubs', 100); % length scale
                param(2) = struct('name', 'sigma_f', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % RBF variance
                param(3) = struct('name', 'sigma_e', 'lb', 0, 'ub', inf, 'lbs', 0, 'ubs', 10); % noise in the generative model
                param(4) = struct('name', 'sigma', 'lb', 0, 'ub', inf, 'lbs', 0, 'ubs', 500); % tau
                param(5) = struct('name', 'sigma', 'lb', 0, 'ub', inf, 'lbs', 10, 'ubs', 100); % response noise
                f = @(x) likfun_GP_sigma(x, data(subject));
                
            end
            
        %set fminunc starting values
        x0 = zeros(1, length(param)); % initialize at zero
        for p = 1:length(param)
            if contains(model, 'gp')
                x0(p) = unifrnd(param(p).lbs, param(p).ubs); 
            elseif strcmp(model, 'gp_recent')
                x0(p) = unifrnd(param(p).lbs, param(p).ubs); 
            else
                x0(p) = unifrnd(param(p).lb, param(p).ub); 
            end
        end
        
        % find min negative log likelihood = maximum likelihood for each subject
        [x, nloglik] = fmincon(f, x0, [], [], [], [], [param.lb], [param.ub]);

            
        % store min negative log likelihood and associated parameter values
            %if starts == 1 || nloglik < results(subject).nll
              %  num_unchanged = 0; %reset to 0 if likelihood changes
                results(subject, start).nll = nloglik;
                results(subject, start).x = x;
            %end
            results(subject, start).sub = subject;
            results(subject, start).model = model;
            results(subject, start).num_params = length(param);
            results(subject, start).nTrials = data(subject).nTrials;
            results(subject, start).AIC = 2*nloglik +2*length(param);
            results(subject, start).BIC = 2*nloglik+length(param)*log(data(subject).nTrials);
            save(results_filename, 'results')
    end
end
   
    
        

end
