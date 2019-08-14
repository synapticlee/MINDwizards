%% Plot exemplar simulation %%
clear all

% Load simulation data
load('../../simulated_exemplar_probabalistic')

% regression coefficients
beta = [.55; .25; .12; .06; .02];


%% Compute regression weights for each subject
for subject = 1:length(sub)
    data = sub(subject);
    theta(subject, 1:5) = regress(data.response', data.bars);
end


%% Plot
figure;

for i = 1:5
    hold on
    plot(theta(:, i));
end

ylabel("Theta")
hold on;
plot(1:25,beta'.* ones(size(theta_sorted(1:25, 1:5))), 'color', 'k')









