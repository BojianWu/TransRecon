function EMGenAlphaMatting(save_path, screen_size)
%% Usage: EMGenAlphaMatting('save_path', [1080 1920])
if isempty(save_path)
    return;
end

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

max_size = max(screen_size(1), screen_size(2));
n = ceil(log(max_size) / log(2));
m = power(2, n);

color_1 = [  0, 255,   0];
color_2 = [255,   0, 255];

x = 0 : m - 1;
y = de2bi(x, n, 'left-msb');

% row
for i = 1 : n
    colorAlphaBkg = zeros(m, m, 3);
    for j = 1 : m
        if y(j, i) == 1
            colorAlphaBkg(j, :, :) = repmat(color_1, m, 1);
        else
            colorAlphaBkg(j, :, :) = repmat(color_2, m, 1);
        end
    end
    colorAlphaBkg = colorAlphaBkg(1:screen_size(1), 1:screen_size(2), :);
    imwrite(colorAlphaBkg, [save_path, '/alpha_', num2str(i), '.png']);
end

% col
for i = 1 : n
    colorAlphaBkg = zeros(m, m, 3);
    for j = 1 : m
        if y(j, i) == 1
            colorAlphaBkg(:, j, :) = repmat(color_1, m, 1);
        else
            colorAlphaBkg(:, j, :) = repmat(color_2, m, 1);
        end
    end
    colorAlphaBkg = colorAlphaBkg(1:screen_size(1), 1:screen_size(2), :);
    imwrite(colorAlphaBkg, [save_path, '/alpha_', num2str(n+i), '.png']);
end

end