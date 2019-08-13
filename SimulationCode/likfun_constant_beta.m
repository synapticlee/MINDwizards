%simulate a situation where the weights are just fixed/constant at 1 

function nloglik = likfun_constant_beta(params, data)

doDebug = false;

sigma  = params(1);

NTrials = length(data.response);
X = data.bars;
for tr = 1:NTrials
    beta_est(tr)    = sum(X(tr,:) * 0.2*ones(5,1)); 
    sim_resp(tr)    = beta_est(tr) + normrnd(0,10);

    xRange  = 0:0.1:100;
    genDist = normpdf(0:0.1:100, sim_resp(tr), sigma); 
    resp    = data.response(tr);

    if doDebug
        figure;
        plot(0:0.1:100,genDist)
        hold on; plot([resp,resp],ylim, 'k--')
        keyboard; cla
    end
    choiceProb(tr) = genDist(find(xRange>= resp, 1, 'first'));
end

%compute negative log likelihood
loglik = sum(log(choiceProb));
nloglik = -1*loglik;

if doDebug
    NRows   = ceil(sqrt(NSubj));
    NPlots  = NRows*NRows;
    figure
    for pl = 1:NPlots
        subplot(NRows,NRows, pl)
        histogram(choiceProb, 0:0.001:0.05)
    end
end
