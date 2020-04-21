% Returns confident matches of feature points between two images
function [matches, confidences] = match_features(features1, features2)

num_features1 = size(features1, 2);
num_features2 = size(features2, 2);
matches = [];
confidences = [];
mc = 1;
% Calculate distances between each features
for i=1:num_features1
    low_d = 9999999;
    sec_low = 9999999;
    f1 = struct2array(features1{i});
    for j=1:num_features2    
        f2 = struct2array(features2{j});
        d = (f1 - f2).^2;
        d = sum(d, 'all');
        d = sqrt(d);
        if d < low_d
            low_d = d;
            ind1 = i;
            ind2 = j;
        elseif d < sec_low
            sec_low = d;
        end
    end
    
    nndr = low_d/sec_low;
    conf = (1-nndr)*100;
    if conf > 25
        matches(mc,:) = [ind1, ind2];
        confidences(mc) = conf;
        mc = mc+1;
    end
end

[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);