% Local Feature Stencil Code


% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2.
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2, feature_width)

% This function does not need to be symmetric (e.g. it can produce
% different numbers of matches depending on the order of the arguments).

% For extra credit you can implement various forms of spatial verification of matches.

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

% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);