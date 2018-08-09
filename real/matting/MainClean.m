clearvars; close all; clear;
%% object path
allObjects = {'dog', 'hand', 'monkey', 'mouse', 'rabbit'};
for count = 1 : length(allObjects)
    objectPath = ['TransRecon-Data\real\', allObjects{count}];

    %% remove alphamatte
    alphamattePath  = [objectPath, '\alphamatte'];

    if exist(alphamattePath, 'dir')
        cd(alphamattePath);
        allFiles = dir('*.png');
        for i = 1 : length(allFiles)
            filename = allFiles(i).name;
            delete(filename);
        end
        cd ..;
    end

    %% remove ray-pixel correspondences
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
            if exist(corresp1Path, 'file')
                delete(corresp1Path);
            end
        end
    end

    %% remove ray-ray correspondences
    K = csvread([objectPath, '/K.csv']);
    proj1 = csvread([objectPath, '/1/proj.csv']);
    proj2 = csvread([objectPath, '/2/proj.csv']);

    rayRayPath = [objectPath, '\RayRayCorresps'];
    if exist(rayRayPath, 'dir')
        cd(rayRayPath);
        allFiles = dir('*.csv');
        for i = 1 : length(allFiles)
            filename = allFiles(i).name;
            delete(filename);
        end
        cd ..;
    end
end