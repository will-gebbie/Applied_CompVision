% Local Feature Stencil Code

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.


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

