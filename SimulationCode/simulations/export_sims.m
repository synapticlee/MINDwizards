
function export_sims(mat_filename, output_name)
%% Export simulated data to CSV

load(mat_filename);

csv_data = zeros(500*1000,11);

for subject = 1:length(sub)
    disp(subject);
    sub_data = sub(subject);
    start_row = 500*(subject-1);
    for trial = 1:sub_data.nTrials
        csv_data(start_row + trial, 1) = subject;
        csv_data(start_row + trial, 2) = trial;
        csv_data(start_row + trial, 3) = sub_data.response(trial);
        csv_data(start_row + trial, 4:8) = sub_data.bars(trial, :);
        csv_data(start_row + trial, 9) = sub_data.correct_response(trial);
        csv_data(start_row + trial, 10) = sub_data.alpha;
        csv_data(start_row + trial, 11) = sub_data.sigma; 
        csv_data(start_row + trial, 12) = sub_data.invTemp; 
    end


end 

csvwrite(output_name, csv_data);


end










