%fitting a model of a single gaussian centred at different mu and sigma

mu              = params(1);
sigma           = params(2);
sigma_noise     = params(3);

NTrials = length(data.response);
X = data.bars;
for tr = 1:NTrials
    gaussWeights = normpdf(1:5, mu, sigma):
    beta_est(tr)    = sum(X(tr,:) * gaussWeights);
    sim_resp(tr)    = beta_est(tr) + normrnd(0,10);

    xRange  = 0:0.1:100;
    genDist = normpdf(0:0.1:100, sim_resp(tr), sigma_noise); 
    resp    = data.response(tr);
end
