% Copies images to last stage of the pipeline while removing the last
% subfolder 
% Path in last stage: .../{pipeline_n}/{person_id}/individual_mov/pic_1.jpg
% Becomes .../{pipeline_n+1}/{person_id}/pic_1.jpg

%% Constant definitions
inputFolder = "processed_5";
outputFolder = "processed_6";
inputBasepath = fullfile("../Dataset", inputFolder);
outputBasepath= fullfile("../Dataset", outputFolder);

%% Iterate over individual people folders creating individual image sets
individualFolders = ListSubfolders(inputBasepath);
imgSetCollection = [];
for folderIdx = 1:size(individualFolders,2)
    folderName = individualFolders{folderIdx};
    
    individualImgSet = CreateImageSetFromSubfolders(fullfile(inputBasepath, folderName), folderName);
    fprintf('Building ImageSet for folder %s with %d images\n', folderName, individualImgSet.Count);
    % Store imageset in array containing image sets for each person
    imgSetCollection = [imgSetCollection, individualImgSet];
end

%% Copy cropped images to next stage of the pipeline all removing subfolder differentiation
numSets = size(imgSetCollection, 2);
for setIdx=1:numSets
    currentSet = imgSetCollection(setIdx);
    for imgIdx = 1:imgSetCollection(setIdx).Count
        originalFullPath = currentSet.ImageLocation(imgIdx);

        [~, imageName, imageExt] = fileparts(char(originalFullPath));
        outFolder = fullfile(outputBasepath, currentSet.Description);
        % Ensure folder exists, suppress warning indicating it already
        % exists
        warning('off', 'MATLAB:MKDIR:DirectoryExists');
        mkdir(outFolder);
        destinationPath = fullfile(outFolder, strcat(imageName,imageExt));      
        
        copyfile(char(originalFullPath), destinationPath)
    end
end