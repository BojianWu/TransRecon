close all; clearvars; clc;
%% main scripts ...
ref_a_path = 'example/reference/ref_alpha';
ref_g_path = 'example/reference/ref_gray';

path = 'example';
obj = 'kitten';
deg = 45;

EMParameters;

for i = 1 : 360 / deg
    rayCorrespSavePath = [path, '/', obj, '/deg_', num2str(deg), '/obj_gray/rayCorresp', num2str(i), '.csv'];
    if exist(rayCorrespSavePath, 'file')
        continue;
    end

    alphamattePath = [path, '/', obj, '/deg_', num2str(deg), '/obj_alpha/alphamatte_', num2str(i), '.png'];
    if ~exist(alphamattePath, 'file')
        obj_a_path = [path, '/', obj, '/deg_', num2str(deg), '/obj_alpha/obj_alpha_', num2str(i)];
        [alphamatte, ~] = EMCompAlphaMatte(ref_a_path, obj_a_path);
        imwrite(alphamatte, alphamattePath);
    end
    
    % plane 1 - ray/pixel correspondence
    plane1ImgDir = [path, '/', obj, '/deg_', num2str(deg), '/obj_gray/obj_gray_', num2str(i), '/1/'];
    if ~exist(plane1ImgDir, 'dir')
        continue;
    end
    corresp1Path = [plane1ImgDir, '/../pixCorresp1.mat'];
    if exist(corresp1Path, 'file')
        load(corresp1Path, 'corresp1');
    else
        corresp1 = EMPixelCorrespBasedOnGray(plane1ImgDir, alphamattePath);
        save([plane1ImgDir, '../pixCorresp1.mat'], 'corresp1');
    end
    
    % plane 2 - ray/pixel correspondence
    plane2ImgDir = [path, '/', obj, '/deg_', num2str(deg), '/obj_gray/obj_gray_', num2str(i), '/2/'];
    if ~exist(plane2ImgDir, 'dir')
        continue;
    end
    corresp2Path = [plane2ImgDir, '/../pixCorresp2.mat'];
    if exist(corresp2Path, 'file')
        load(corresp2Path, 'corresp2');
    else
        corresp2 = EMPixelCorrespBasedOnGray(plane2ImgDir, alphamattePath);
        save([plane2ImgDir, '../pixCorresp2.mat'], 'corresp2');
    end
    
    % plane 2 -> plane 1 - ray/ray correspondence
    %
    %           |          |
    %           |          |
    %           |          |
    %        plane 2 -> plane 1 (Ray will traverse from plane 2 to plane 1)
    %
    if isempty(corresp1) || isempty(corresp2)
        continue;
    end
    
    h = size(corresp1, 1);
    w = size(corresp1, 2);
    dh = 1 / h;
    dw = 1 / w;
    pixelCnt = h * w;
    rayCorresp = zeros(pixelCnt, 12);
    
    alphamatte = rgb2gray(imread(alphamattePath));
    alphamatte(alphamatte > 1) = 1;
    
    for y = 1 : h
        for x = 1 : w
            pixelIdx = x + (y - 1) * w;
            u = (x - 0.5) * dw;
            v = (y - 0.5) * dh;
            
            rayOrg = camPos;
            rayDir = (imgLUCorner + u * imgXDir + v * imgYDir) - rayOrg;
            rayDir = rayDir / norm(rayDir);      % normalization
            
            rayCorresp(pixelIdx, 1:3) = rayOrg;
            rayCorresp(pixelIdx, 4:6) = rayDir;
            
            if ~alphamatte(y, x)
                orgS = (plane2LUCorner(3) - rayOrg(3)) / rayDir(3);
                orgX = rayOrg(1) + orgS * rayDir(1);
                orgY = rayOrg(2) + orgS * rayDir(2);
                orgZ = plane2LUCorner(3);
                rayCorresp(pixelIdx, 7:9) = [orgX, orgY, orgZ];
                rayCorresp(pixelIdx, 10:12) = rayDir;
                continue;
            end
            
            pIdx1 = squeeze(corresp1(y, x, :));
            pIdx2 = squeeze(corresp2(y, x, :));
            
            u1 = (pIdx1(2) - 0.5) * dw;
            v1 = (pIdx1(1) - 0.5) * dh;
            pixelPos1 = plane1LUCorner + u1 * planeXDir + v1 * planeYDir;
            
            u2 = (pIdx2(2) - 0.5) * dw;
            v2 = (pIdx2(1) - 0.5) * dh;
            pixelPos2 = plane2LUCorner + u2 * planeXDir + v2 * planeYDir;
            
            outputRay = pixelPos2;
            outputDir = pixelPos1 - pixelPos2;
            outputDir = outputDir / norm(outputDir);
            
            rayCorresp(pixelIdx, 7:9)   = outputRay;
            rayCorresp(pixelIdx, 10:12) = outputDir;
        end
    end
    dlmwrite(rayCorrespSavePath, rayCorresp, 'delimiter', ',', 'precision', 15);
end

clearvars;