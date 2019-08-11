function sub = loadData(datadir)

count = 1;

for i = 1:length(datadir)
    cd(datadir{i})
    d = dir('*.csv');
    
    for sn = 1:length(d)
        fid = fopen(d(sn).name);
        hdr = textscan(fid,  '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 1, 'delimiter', ',');
        data = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',  'delimiter', ',');
        fclose(fid);
        
        sub(count).correct_response = data{1};
        sub(count).response = data{2};
        sub(count).bars = [data{5:9}];
        sub(count).weights = [data{10:14}];
        sub(count).condition = data{15};
        sub(count).RT = data{16};
        
        [~,ind] = sort(sub(count).weights(1,:), 'descend');
        sub(count).weights_sorted = sub(count).weights(:,ind);
        sub(count).bars_sorted = sub(count).bars(:,ind);
        sub(count).nTrials = length(sub(count).response);
        sub(count).error = sub(count).correct_response - sub(count).response;
        
        dum = sub(count).condition;
        sub(count).block = cumsum([1; abs(diff(dum))]);
        count = count + 1;
    end
end
