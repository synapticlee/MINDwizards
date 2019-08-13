%fitting a model of a single gaussian centred at different mu and sigma

mu      = params(1);
sigma   = params(2);

NTrials = length(data.response);
X = data.bars;
for tr = 1:NTrials
    beta_est(tr)    = sum(X(tr,:) * 0.2*ones(5,1)); 
    sim_resp(tr)    = beta_est(tr) + normrnd(0,10);

    xRange  = 0:0.1:100;
    genDist = normpdf(0:0.1:100, sim_resp(tr), sigma); 
    resp    = data.response(tr);
end
