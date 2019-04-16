%% Constant definitions
inputFolder = "processed_4";
outputFolder = "processed_5";
inputBasepath = fullfile("../Dataset", inputFolder);
outputBasepath= fullfile("../Dataset", outputFolder);

%% Create Normalized Image Set Collection with ann individuals pictures
disp("Building ImageSet Collection...");
imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);

%% Iterate over each image performing transformations
disp("Performing image normalization...");
numSets = size(imgSetCollection, 2);
for setIdx=1:numSets
    currentSet = imgSetCollection(setIdx);
    for imgIdx = 1:imgSetCollection(setIdx).Count
        % Read image
        currentImage = read(currentSet, imgIdx);
        
        % Normalize image
        currentImage = NormalizeImage(currentImage);
        
        % Output processed image
        % Write processed image to next folder while keep the exact same 
        % path structure only changing the pipeline stage folder
        [imagePath, imageName, imageExt] = fileparts(char(currentSet.ImageLocation(imgIdx)));
        outFolder = strrep(imagePath, inputFolder, outputFolder); 
        outFilepath = fullfile(outFolder, strcat(imageName,imageExt));
        % Ensure folder exists, suppress warning indicating it already
        % exists
        warning('off', 'MATLAB:MKDIR:DirectoryExists');
        mkdir(outFolder);

        % Writes image to next stage in the pipeline
        imwrite(currentImage, outFilepath);
    end
end

disp("Done!");