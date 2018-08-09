clearvars; close all; clear;
%% parameters
imgW = 1280;
imgH = 960;

pix = 0.27;         % pixel pitch of DELL U2412M (http://www.dell.com/hr/business/p/dell-u2412m/pd)
hReal = 1200 * pix; % height
wReal = 1920 * pix; % width
num_of_views = 72;

allObjects = {'dog', 'hand', 'monkey', 'mouse', 'rabbit'};
for count = 1 : length(allObjects)
    objectPath = ['TransRecon-Data\real\', allObjects{count}];

    % alphamatte extraction
    objAlphaPath    = [objectPath, '\1\obj_gray'];
    objAlphaRefPath = [objectPath, '\1\reference'];
    alphamattePath  = [objectPath, '\alphamatte'];

    if ~exist(alphamattePath, 'dir')
        mkdir(alphamattePath);
    end

    if ~exist(objAlphaPath, 'dir') || ~exist(objAlphaRefPath, 'dir')
        return;
    end

    allSubDir = dir(objAlphaPath);
    parfor i = 1 : length(allSubDir)
        dirName = allSubDir(i).name;
        if strcmp(dirName, '.') || strcmp(dirName, '..')
            continue;
        end

        alphamatte = EMXCompAlphaMatte(objAlphaRefPath, [objAlphaPath, '\', dirName]);
        str = strsplit(dirName, '_');
        filename = sprintf('%s/alphamatte_%02d.png', alphamattePath, str2num(str{3}));
%         imwrite(alphamatte, filename);
    end

    %% ray-pixel correspondences
    for k = 1 : 2
        objGrayPath = [objectPath, '\', num2str(k), '\obj_gray'];
        if ~exist(objGrayPath, 'dir')
            return;
        end
        allSubDirs = dir(objGrayPath);
        for i = 1 : length(allSubDirs)
            dirName = allSubDirs(i).name;
            if strcmp(dirName, '.') || strcmp(dirName, '..')
                continue;
            end

            objGrayDir = [objGrayPath, '/', dirName];
            if ~exist(objGrayDir, 'dir')
                continue;
            end

            corresp1Path = [objGrayDir, '/pixCorresp1.mat'];
            temp = strsplit(dirName, '_');        
            amPath = sprintf('%s/alphamatte_%02d.png', alphamattePath, str2num(temp{3}));
            corresp1 = EMPixelCorrespBasedOnGray(objGrayDir, amPath);
            save([objGrayDir, '/pixCorresp1.mat'], 'corresp1');
        end
    end

    %% ray-ray correspondences
    K = csvread([objectPath, '/K.csv']);
    proj1 = csvread([objectPath, '/1/proj.csv']);
    proj2 = csvread([objectPath, '/2/proj.csv']);

    rayRayPath = [objectPath, '\RayRayCorresps'];
    if ~exist(rayRayPath, 'dir')
        mkdir(rayRayPath);
    end

    R1 = proj1(:, 1:3); T1 = proj1(:, 4);
    R2 = proj2(:, 1:3); T2 = proj2(:, 4);
    cam_proj = csvread([objectPath, '/cam_proj.csv']);

    hRealHalf = hReal / 2.0;
    wRealHalf = wReal / 2.0;
    cornerLU  = [-wRealHalf, hRealHalf, 0.0];

    for i = 1 : num_of_views
        alphamatte = imread(sprintf('%s/alphamatte_%02d.png', alphamattePath, i));
        alphamatte = rgb2gray(alphamatte);

        h = size(alphamatte, 1);
        w = size(alphamatte, 2);
        rayCorresp = zeros(h * w, 12);
        
        pixCorresp1Path = sprintf('%s/1/obj_gray/obj_gray_%02d/pixCorresp1.mat', objectPath, i);
        pixCorresp2Path = sprintf('%s/2/obj_gray/obj_gray_%02d/pixCorresp1.mat', objectPath, i);
        
        load(pixCorresp1Path); pixCorresp1 = corresp1; clear corresp1;
        load(pixCorresp2Path); pixCorresp2 = corresp1; clear corresp1;
        clear pixCorresp1Path pixCorresp2Path;

        R = cam_proj((i-1)*3+1:i*3, 1:3);
        T = cam_proj((i-1)*3+1:i*3, 4);

        cnt = 1;

        for y = 1 : h
            for x = 1 : w
                cam_cam = [0 0 0];
                pix_cam = inv(K) * [x y 1]';
                pix_cam = pix_cam';

                cam_rt = R' * (cam_cam' - T);
                pix_rt = R' * (pix_cam' - T);

                inP = cam_rt;
                inD = pix_rt - cam_rt;
                inD = inD / norm(inD);

                if alphamatte(y, x) == 0
                    outP = inP + inD * 1500;
                    outD = inD;
                else
                    r1 = pixCorresp1(y, x, 1);
                    c1 = pixCorresp1(y, x, 2);
                    p1 = cornerLU + [c1 * pix, -r1 * pix, 0.0];
                    p1_cam = R1 * p1' + T1;
                    p1_rt  = R' * (p1_cam - T);

                    r2 = pixCorresp2(y, x, 1);
                    c2 = pixCorresp2(y, x, 2);
                    p2 = cornerLU + [c2 * pix, -r2 * pix, 0.0];
                    p2_cam = R2 * p2' + T2;
                    p2_rt  = R' * (p2_cam - T);

                    outP = p1_rt;
                    outD = p2_rt - p1_rt;
                    outD = outD / norm(outD);
                end

                rayCorresp(cnt, :) = [inP' inD' outP' outD'];
                cnt = cnt + 1;
            end
        end

        rayCorrespPath = [rayRayPath, '/rayCorresp', num2str(i), '.csv'];
        csvwrite(rayCorrespPath, rayCorresp);
    end
end