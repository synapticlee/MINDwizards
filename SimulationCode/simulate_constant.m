%simulate a situation where the weights are just fixed/constant at 1 

%function simulate_constant(X, )


for sj = 1:length(sub)
    NTrials = length(sub(sj).response);
    X = sub(sj).bars;
    for tr = 1:NTrials
        beta_est{sj}(tr)    = sum(X(tr,:) * 0.2*ones(5,1)); 
        val{sj}(tr)         = beta_est{sj}(tr) + normrnd(0,10);
    end
    resp        = sub(sj).response;
    simil(sj)   = corr(resp(:),val{sj}(:));
end

