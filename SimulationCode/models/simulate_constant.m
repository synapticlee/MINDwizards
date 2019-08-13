%simulate a situation where the weights are just fixed/constant at 1 

function choiceProb = simulate_constant() %X, pars)

doDebug = false;
addpath(genpath('~/OneDrive - University College London/15_SummerSchools/MIND/MINDwizards'))

main_v1();

pars.sigma  = 20;

NSubj = length(sub);
for sj = 1:NSubj
    NTrials = length(sub(sj).response);
    X = sub(sj).bars;
    for tr = 1:NTrials
        beta_est{sj}(tr)    = sum(X(tr,:) * 0.2*ones(5,1)); 
        sim_resp{sj}(tr)    = beta_est{sj}(tr) + normrnd(0,10);

        xRange  = 0:0.1:100;
        genDist = normpdf(0:0.1:100, sim_resp{sj}(tr), pars.sigma); 
        resp    = sub(sj).response(tr);

        if doDebug
            figure;
            plot(0:0.1:100,genDist)
            hold on; plot([resp,resp],ylim, 'k--')
            keyboard; cla
        end
        choiceProb{sj}(tr) = genDist(find(xRange>= resp, 1, 'first'));
    end
end

NRows   = ceil(sqrt(NSubj));
NPlots  = NRows*NRows;
figure
for pl = 1:NPlots
    subplot(NRows,NRows, pl)
    histogram(choiceProb{sj}, 0:0.001:0.05)
end
