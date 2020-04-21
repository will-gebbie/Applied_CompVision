function pyramid(inputImg)
% Convert query image to grayscale and new image for threshold
query = rgb2gray(imread(inputImg));

% Crop template of your choosing
[template, rect] = imcrop(query);

% Calculate center of template for future reference
xcen = rect(1) + .5*rect(3);
ycen = rect(2) + .5*rect(4);
temp_cen = [xcen, ycen];

% Resize template images
query34 = imresize(query, 0.75);
temp34 = imresize(template, 0.75);
queryhalf = imresize(query, 0.5);
temphalf = imresize(template, 0.5);
query14 = imresize(query, 0.25);
temp14 = imresize(template, 0.25);

templates = {template, temp34, temphalf, temp14};
queries = {query, query34, queryhalf, query14};
centers = {temp_cen, temp_cen*0.75, temp_cen/2, temp_cen*0.25};
pairs = {{templates(1), queries(1), centers(1)}, {templates(2), queries(2), centers(2)}, ...
    {templates(3), queries(3), centers(3)}, {templates(4), queries(4), centers(4)}};

scale = 1.0;
for pair = pairs
    curr_q = pair{1}{2}{1};
    curr_cen = pair{1}{3}{1};
    q_mean = mean(curr_q, 'all');
    temp = pair{1}{1}{1};
    s = size(temp);
    temp = im2double(temp);
    if mod(s(1), 2) == 0
        temp(size(temp,1),:) = [];
    end
    if mod(s(2), 2) == 0
        temp(:,size(temp,2)) = [];
    end
    pad_zeros = (size(temp)-1)/2;
    % Create padded image and image to be filled
    query_pad = padarray(curr_q, pad_zeros, 0);
    query_pad = im2double(query_pad);
    dims = size(query_pad);
    thresh_zm = zeros(dims);
    thresh_ssd = zeros(dims);
    thresh_ncc = zeros(dims);
    % Sliding Window Routine
    for i = 1 + pad_zeros(1):dims(1) - pad_zeros(1)
        for j = 1 + pad_zeros(2):dims(2) - pad_zeros(2)
            % Calculate for each method and populate thresh matrix
            f_chunk = query_pad(i-pad_zeros(1):i+pad_zeros(1) ...
                ,j-pad_zeros(2):j+pad_zeros(2));
            % Sum of squared differences
            ssd = temp - f_chunk;
            ssd = ssd .^ 2;
            % Zero Mean
            zm = f_chunk - q_mean;
            zm = zm .* temp;
            % Normalized Cross Correlation Method
            ncc_num = (temp - mean(temp, 'all'));
            ncc_num = ncc_num .* (f_chunk - mean(f_chunk, 'all'));
            ncc_num = sum(ncc_num, 'all');
            ncc_den1 = (temp - mean(temp, 'all')).^2;
            ncc_den1 = sum(ncc_den1, 'all');
            ncc_den2 = (f_chunk - mean(f_chunk, 'all')).^2;
            ncc_den2 = sum(ncc_den2, 'all');
            ncc_den = ncc_den1 * ncc_den2;
            ncc_den = sqrt(double(ncc_den));
            ncc = ncc_num/ncc_den;
            
            thresh_ssd(i, j) = sum(ssd(:));
            thresh_zm(i, j) = sum(zm(:));
            thresh_ncc(i, j) = ncc;
        end
    end
    % Crop Extra Zeros
    thresh_ssd = thresh_ssd(1 + pad_zeros(1):dims(1) - pad_zeros(1), ...
        1 + pad_zeros(2):dims(2) - pad_zeros(2));
    thresh_zm = thresh_zm(1 + pad_zeros(1):dims(1) - pad_zeros(1), ...
        1 + pad_zeros(2):dims(2) - pad_zeros(2));
    thresh_ncc = thresh_ncc(1 + pad_zeros(1):dims(1) - pad_zeros(1), ...
        1 + pad_zeros(2):dims(2) - pad_zeros(2));
    
    percent = scale * 100;
    fprintf('Scale: %3.1f%%\n', percent);
    fmt = 'Real Center: (%4.2f, %4.2f)\n';
    fprintf(fmt, curr_cen);
    thresh_ssd = mat2gray(thresh_ssd);
    thresh_ssd = im2bw(thresh_ssd, .07);
    fig = figure;
    subplot(2, 2, 1);
    imshow(thresh_ssd);
    title('SSD');
    [ty, tx] = find(thresh_ssd == 0);
    tx = double(median(tx));
    ty = double(median(ty));
    ssd_cen = [tx ty];
    loc_ssd = ssd_cen - curr_cen;
    loc_ssd = loc_ssd.^2;
    loc_ssd = sqrt(sum(loc_ssd, 'all'));
    
    
    thresh_zm = mat2gray(thresh_zm);
    thresh_zm = im2bw(thresh_zm, .9);
    subplot(2, 2, 2);
    imshow(thresh_zm);
    title('Zero Mean');
    [ty, tx] = find(thresh_zm == 1);
    tx = double(median(tx));
    ty = double(median(ty));
    zm_cen = [tx ty];
    loc_zm = zm_cen - curr_cen;
    loc_zm = loc_zm.^2;
    loc_zm = sqrt(sum(loc_zm, 'all'));
    
    thresh_ncc = mat2gray(thresh_ncc);
    thresh_ncc = im2bw(thresh_ncc, .9);
    subplot(2, 2, 3);
    imshow(thresh_ncc);
    title('NCC');
    [ty, tx] = find(thresh_ncc == 1);
    tx = double(median(tx));
    ty = double(median(ty));
    ncc_cen = [tx ty];
    loc_ncc = ncc_cen - curr_cen;
    loc_ncc = loc_ncc.^2;
    loc_ncc = sqrt(sum(loc_ncc, 'all'));
    
    subplot(2, 2, 4);
    imshow(curr_q);
    title('Original');
    
    txt = [num2str(percent), '% Scale'];
    sgtitle(txt);
    fprintf('SSD Center: (%4.2f,%4.2f), Error: %4.3f\n',ssd_cen,loc_ssd);
    fprintf('Zero Mean Center: (%4.2f,%4.2f), Error: %4.3f\n',zm_cen,loc_zm);
    fprintf('NCC Center: (%4.2f,%4.2f), Error: %4.3f\n\n',ncc_cen,loc_ncc);
    
    scale = scale - 0.25;
    
end
end

