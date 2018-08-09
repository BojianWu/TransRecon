function EMXGenGrayPattern(save_path, pattern_size, screen_size, output_video_path)
%% genGrayPattern generate Gray coded backdrop pattern
%   Arguments:
%       path : path to save backdrop images
%       pSize: pattern size  [h, w],
%       sSize: screen size   [h, w], should always be less than pSize
%       outputVideo: a boolean variable to indicate whether to write video
if isempty(save_path)
    return;
end

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

if screen_size(1) < pattern_size(1) || screen_size(2) < pattern_size(2)
    return;
end

max_size = max(pattern_size(1), pattern_size(2));
n = ceil(log(max_size) / log(2));
m = power(2,n);
x = (0 : m-1)';
y = bin2gray(x, 'psk', m);

z = zeros(m, n);
for i = 1 : m
    z(i, :) = bitget(y(i), n:-1:1);
end

yRange = screen_size(1)/2 - pattern_size(1)/2 + 1 : screen_size(1)/2 + pattern_size(1)/2;
xRange = screen_size(2)/2 - pattern_size(2)/2 + 1 : screen_size(2)/2 + pattern_size(2)/2;

% row
for i = 1 : n
    greyPattern = zeros(m ,m);
    for j = 1 : m
        greyPattern(j, :) = z(j, i);        
    end
    greyPattern = greyPattern(1:pattern_size(1), 1:pattern_size(2), 1);
    rgbPattern = zeros(screen_size(1), screen_size(2), 3);
    rgbPattern(yRange, xRange, :) = repmat(greyPattern, [1,1,3]);
    imwrite(rgbPattern, [save_path, '/row_gray_', num2str(i), '.png']);
end

% col
for i = 1 : n
    greyPattern = zeros(m, m);
    for j = 1 : m
        greyPattern(:, j) = z(j, i);
    end
    greyPattern = greyPattern(1:pattern_size(1), 1:pattern_size(2), 1);
    rgbPattern = zeros(screen_size(1), screen_size(2), 3);
    rgbPattern(yRange, xRange, :) = repmat(greyPattern, [1,1,3]);
    imwrite(rgbPattern, [save_path, '/col_gray_', num2str(i), '.png']);
end

if ~isempty(output_video_path)
    % TODO
end

end