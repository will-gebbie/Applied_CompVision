function averageOfSets(directory)

imgSet = dir(directory); % load in images from a given directory
imgSet = imgSet(~ismember({imgSet.name}, {'.', '..'})); % exclude . and .. objects

numImages = size(imgSet, 1); 

sumImagesRGB = [];
sumImagesGray = [];

% 3D array containing all grayscale images in a set
arrayOfGrays = [];

for i = 1:numImages
    imageDir = strcat(directory, '\', imgSet(i).name);
    
    currImageRGB = imread(imageDir);
    currImageGray = rgb2gray(currImageRGB);
    
    convertDoubleRGB = double(currImageRGB);
    convertDoubleGray = double(currImageGray);
    
    if i == 1
        sumImagesRGB = convertDoubleRGB;
        sumImagesGray = convertDoubleGray;
        arrayOfGrays(:, :, i) = convertDoubleGray;
    else
        sumImagesRGB = sumImagesRGB + convertDoubleRGB;
        sumImagesGray = sumImagesGray + convertDoubleGray;
        arrayOfGrays(:, :, i) = convertDoubleGray;
    end
end

% Divide the sum of each pixel by total number of images
avgRGB = sumImagesRGB / numImages;
avgGray = sumImagesGray / numImages;

% Calculate standard deviation on 3rd dimension of array of images
stdDevOfSets = std(arrayOfGrays, 0, 3);

% Convert double form of back to integers
imRGB = uint8(avgRGB);
imGray = uint8(avgGray);
imStd = uint8(stdDevOfSets);

% Plot both of the images together
figure;
subplot(1, 2, 1);
imagesc(imRGB);
title('RGB Average');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
axis square;

subplot(1, 2, 2);
imagesc(imGray);
title('Grayscale Average');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
colormap gray;
axis square;

figure;
imagesc(imStd);
title('Standard Deviation');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
colormap gray;
axis square;


end