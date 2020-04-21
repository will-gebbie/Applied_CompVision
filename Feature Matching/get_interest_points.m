% Returns a set of interest points for the input image

function [x, y] = get_interest_points(image, feature_width)

% Step 1: Compute hor. and vert. derivatives with DoG

% Gaussian Filter
h = fspecial('gaussian', 5, 0.5);
% Derivatives of Gaussians in X and Y directions
DoGx = imfilter(h, [-1 1]);
DoGy = imfilter(h, [-1;1]);
% Compute Images
Ix = imfilter(image, DoGx);
Iy = imfilter(image, DoGy);

% Step 2: Ix^2, Iy^2, and IxIy
Ix2 = Ix .^ 2;
Iy2 = Iy .^ 2;
IxIy = Ix .* Iy;

% Step 3: Larger Gaussian Filter Applied
h = fspecial('gaussian', 10, 0.5);
Gx2 = imfilter(Ix2, h);
Gy2 = imfilter(Iy2, h);
Gxy = imfilter(IxIy, h);

% Step 4: Cornerness function
alpha = 0.04;
score = (Gx2 .* Gy2) - (Gxy .^ 2) - (alpha * ((Gx2 + Gy2) .^ 2));

% Calculate Threshold
sort_score = sort(score(:),'descend');
top_half = sort_score(1:ceil(length(sort_score)*0.005));
thresh = top_half(length(top_half));
score(score < thresh) = 0;
% Take off points too close to horizontal edges
score([1:feature_width, size(score,1)-feature_width-1:size(score,1)], :) = 0;
% Same with vertical edges
score(:,[1:feature_width, size(score,2)-feature_width:size(score,2)]) = 0;
% Take maxes at each window of size feature/4 because of descriptors
maxes = colfilt(score,[feature_width/4, feature_width/4],'sliding',@max);
% Only find indexes of non-max-supressed corners
new_corners = score.*(score == maxes);
[y,x] = find(new_corners);

end

