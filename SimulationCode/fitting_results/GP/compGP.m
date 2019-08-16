cd('/Users/jlee/OneDrive - University College London/15_SummerSchools/MIND/MINDwizards/SimulationCode/fitting_results/GP')

gp_nll = NaN(41,1);
gp_AIC = NaN(41,1);
gp_BIC = NaN(41,1);
gpr_nll = NaN(41,1);
gpr_AIC = NaN(41,1);
gpr_BIC = NaN(41,1);


for subj = 1:41
    try
        gp  = load(sprintf('GPpertrial_sub%d.mat', subj));
        gpr = load(sprintf('GPrecent_sub%d.mat', subj));
        gps = load(sprintf('GPrecentsigma_sub%d.mat', subj));

        gp_nll(subj) = gp.results.nll;
        gp_AIC(subj) = gp.results.AIC;
        gp_BIC(subj) = gp.results.BIC;
        gpr_nll(subj) = gpr.results.nll;
        gpr_AIC(subj) = gpr.results.AIC;
        gpr_BIC(subj) = gpr.results.BIC;
        gprs_nll(subj) = gpr.results.nll;
        gprs_AIC(subj) = gpr.results.AIC;
        gprs_BIC(subj) = gpr.results.BIC;
    catch
        gp_nll(subj)    = NaN;
        gp_AIC(subj)    = NaN;
        gp_BIC(subj)    = NaN;
        gpr_nll(subj)   = NaN;
        gpr_AIC(subj)   = NaN;
        gpr_BIC(subj)   = NaN;
        gprs_nll(subj)  = NaN;
        gprs_AIC(subj)  = NaN;
        gprs_BIC(subj)  = NaN;
    end
end
