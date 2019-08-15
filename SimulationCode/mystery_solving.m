%% Why is the exemplar model systematically biased?

%Load exemplar data
load('../../simulated_exemplar_highTrialMem_withRefTrials')


%Identify trials that were sampled 5 or more times for each subject
for subject = 1:length(sub)
    sub_data = sub(subject);
    [a,b]= hist(sub_data.reference_trial,unique(sub_data.reference_trial));
    oversampled_indices = find(a > 4);
    oversampled_bars = sub_data.bars(oversampled_indices, :);
    other_bars = sub_data.bars(a <= 4, :);
    sample_entropy(subject) = mean(-1*sum(oversampled_bars'/100.*log(oversampled_bars'./100)));
    other_entropy(subject) = mean(-1*sum(other_bars'/100.*log(other_bars'./100)));
end

nanmean(sample_entropy)
nanmean(other_entropy)

