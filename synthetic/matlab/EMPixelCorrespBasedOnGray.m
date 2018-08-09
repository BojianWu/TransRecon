function corresp = EMPixelCorrespBasedOnGray(img_path, alphamatte_path)
%% pixelCorrespondence compute correspondence between pixel on 
% params
thres = 0.50;

% load row images
rowImgs = dir([img_path, '/row_*.png']);
rowImgsCnt = length(rowImgs);
allRowImgs = cell(rowImgsCnt, 1);

for i = 1 : rowImgsCnt
    rowImg = rgb2gray(im2double(imread([img_path, '/row_gray_', num2str(i, '%02d'), '.png'])));
%     rowImg(rowImg <  0.5) = 0;
%     rowImg(rowImg >= 0.5) = 1;
    allRowImgs{i} = rowImg;
end

h = size(allRowImgs{1}, 1);
w = size(allRowImgs{2}, 2);
corresp = zeros(h, w, 2);       % row and col index

if isempty(alphamatte_path)
    alphamatte = ones(h, w);
else
    alphamatte = rgb2gray(imread(alphamatte_path));
    alphamatte(alphamatte > 0) = 1;
end

if size(alphamatte, 1) ~= h || size(alphamatte, 2) ~= w
    return;
end

% compute index
m = power(2, rowImgsCnt);
s = 0 : m-1;
d = bin2gray(s, 'psk', m);

parfor y = 1 : h
    for x = 1 : w
        if ~alphamatte(y, x)
            corresp(y, x, 1) = -1;
            continue;
        end        
        v = zeros(rowImgsCnt, 1);
        for i = 1 : rowImgsCnt
            v(i) = allRowImgs{i}(y, x);
        end
        v(v >  thres) = 1;
        v(v <= thres) = 0;
        % in alphamatte, but can not be illuminated by background patterns
        if range(v) == 0
            corresp(y, x, 1) = -2;
            continue;
        end
        ind = (d == bi2de(v', 'left-msb'));
        corresp(y, x, 1) = s(ind) + 1;
    end
end

clear rowImgs

% load col images
colImgs = dir([img_path, '/col_*.png']);
colImgsCnt = length(colImgs);
allColImgs = cell(colImgsCnt, 1);

for i = 1 : colImgsCnt
    colImg = rgb2gray(im2double(imread([img_path, '/col_gray_', num2str(i, '%02d'), '.png'])));
%     colImg(colImg <  0.5) = 0;
%     colImg(colImg >= 0.5) = 1.0;
    allColImgs{i} = colImg;
end

if size(allColImgs{1}, 1) ~= h || size(allColImgs{1}, 2) ~= w
    return;
end

m = power(2, colImgsCnt);
s = 0 : m-1;
d = bin2gray(s, 'psk', m);

parfor y = 1 : h
    for x = 1 : w
        if ~alphamatte(y, x)
            corresp(y, x, 2) = -1;
            continue;
        end
        v = zeros(colImgsCnt, 1);
        for i = 1 : colImgsCnt
            v(i) = allColImgs{i}(y, x);
        end
        v(v >  thres) = 1;
        v(v <= thres) = 0;
        % in alphamatte, but can not be illuminated by background patterns
        if range(v) == 0
            corresp(y, x, 2) = -2;
            continue;
        end
        ind = (d == bi2de(v', 'left-msb'));
        corresp(y, x, 2) = s(ind) + 1;
    end    
end

clear colImgs

end