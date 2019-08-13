%fitting a model of a single gaussian centred at different mu and sigma
%no intercept because it needs to be normalized to have a sum of 1 anyway 

function nloglik = likfun_linear(params, data)

slope           = params(1);
%possible values: -1:1
sigma_noise     = params(2);

linearFunc      = [[1:5]*slope]/sum([1:5]*slope);

NTrials = length(data.response);
X = data.bars;
for tr = 1:NTrials
    beta_est(tr)    = sum(X(tr,:) * linearFunc(:));
    sim_resp(tr)    = beta_est(tr) + normrnd(0,sigma_noise);

    xRange  = 0:0.1:100;
    genDist = normpdf(0:0.1:100, sim_resp(tr), sigma_noise); 
    resp    = data.response(tr);
    choiceProb(tr) = genDist(find(xRange>= resp, 1, 'first'));
end

%compute negative log likelihood
loglik = sum(log(choiceProb));
nloglik = -1*loglik;
