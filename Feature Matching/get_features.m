% Returns a set of feature descriptors for a given set of interest points.
function [features] = get_features(image, x, y, feature_width)

numCoords = size(x, 1);
boxes = {};

% Make feature boxes
for i=1:numCoords
    boxes{i} = image(y(i)-(feature_width/2):y(i)+(feature_width/2)-1, ...
        x(i)-(feature_width/2):x(i)+(feature_width/2)-1);
end

% Algorithm to separate large patch into sub blocks
grid_size = feature_width/4 - 1;
fours = {};
curr_cell = {};
for i=1:numCoords
    currx = 1;
    curry = 1;
    k = 1;
    while k <= (feature_width/4)^2
        % 16 subblocks of 4x4 for each box
        if currx == curry
            s = boxes{i}(currx:currx+grid_size, curry:curry+grid_size);
            curr_cell{k} = s;
            k = k+1;
            curry = curry+3;
            s = boxes{i}(currx:currx+grid_size, curry:curry+grid_size);
            curr_cell{k} = s;
            k = k+1;
        elseif currx < curry
            temp = curry;
            curry = currx;
            currx = currx+3;
            s = boxes{i}(currx:currx+grid_size, curry:curry+grid_size);
            curr_cell{k} = s;
            k = k+1;
            curry = temp;
            s = boxes{i}(currx:currx+grid_size, curry:curry+grid_size);
            curr_cell{k} = s;
            k = k+1;
        end
    end
    fours{i} = curr_cell;
end

% fours now contains all sub blocks corresponding to each feature patch
% Create Histogram for each cell
hists = {};
curr_hist = {};
for i=1:numCoords
    for j=1:feature_width
        % Get gradient direction and magnitude
        [Gmag, Gdir] = imgradient(fours{i}{j});
        % 8 bin histogram structure
        h = struct('a',0,'b',0,'c',0,'d',0 ...
            ,'e',0,'f',0,'g',0, 'h',0);
        for k=1:feature_width
            if Gdir(k) >= 0 && Gdir(k) < 45
                z = (45 - Gdir(k))/45 * Gmag(k);
                f = (Gdir(k))/45 * Gmag(k);
                h.a = h.a + z;
                h.b = h.b + f;
            elseif Gdir(k) >= 45 && Gdir(k) < 90
                f = (90 - Gdir(k))/45 * Gmag(k);
                n = (Gdir(k)-45)/45 * Gmag(k);
                h.b = h.b + f;
                h.c = h.c + n;
            elseif Gdir(k) >= 90 && Gdir(k) < 135
                n = (135 - Gdir(k))/45 * Gmag(k);
                t = (Gdir(k)-90)/45 * Gmag(k);
                h.c = h.c + n;
                h.d = h.d + t;
            elseif Gdir(k) >= 135 && Gdir(k) <= 180
                t = (180 - Gdir(k))/45 * Gmag(k);
                e = (Gdir(k)-135)/45 * Gmag(k);
                h.d = h.d + t;
                h.e = h.e + e;
            elseif Gdir(k) >= -180 && Gdir(k) < -135
                nt = -(-180 - Gdir(k))/45 * Gmag(k);
                ne = -(Gdir(k)+ 135)/45 * Gmag(k);
                h.e = h.e + ne;
                h.f = h.f + nt;
            elseif Gdir(k) >= -135 && Gdir(k) < -90
                nn = -(-135 - Gdir(k))/45 * Gmag(k);
                nt = -(Gdir(k)+ 90)/45 * Gmag(k);
                h.f = h.f + nt;
                h.g = h.g + nn;
            elseif Gdir(k) >= -90 && Gdir(k) < -45
                nf = -(-90 - Gdir(k))/45 * Gmag(k);
                nn = -(Gdir(k)+ 45)/45 * Gmag(k);
                h.g = h.g + nn;
                h.h = h.h + nf;
            elseif Gdir(k) >= -45 && Gdir(k) < 0
                z = -(-45 - Gdir(k))/45 * Gmag(k);
                nf = -(Gdir(k))/45 * Gmag(k);
                h.h = h.g + nf;
                h.a = h.a + z;
            end
        end
        curr_hist{j} = h;
    end
    hists{i} = curr_hist;
end

% normalize histograms
normal_hist = {};
for i=1:numCoords

    curr_block = hists{i};
    h = struct('a',0,'b',0,'c',0,'d',0 ...
            ,'e',0,'f',0,'g',0, 'h',0);
    for j=1:feature_width
        curr_hist = curr_block{j};
        total = sum(struct2array(curr_hist),'all');
        h.a = curr_hist.a/total;
        h.b = curr_hist.b/total;
        h.c = curr_hist.c/total;
        h.d = curr_hist.d/total;
        h.e = curr_hist.e/total;
        h.f = curr_hist.f/total;
        h.g = curr_hist.g/total;
        h.h = curr_hist.h/total;
        normal_hist{j} = h;
    end
    hists{i} = normal_hist;

end

% Format Cell Arrays into 4x4x8 Vectors
formatCell = {};
fw = feature_width/4;
for i=1:numCoords
    currBlock = hists{i};
    % Reshape into feature_width/4
    currBlock = reshape(currBlock, [fw,fw]);
    % Cell to matrix of structs
    currBlock = cell2mat(currBlock);

    formatCell{i} = currBlock;
end
features = formatCell;
end








