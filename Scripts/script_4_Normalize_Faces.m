%% Constant definitions
inputFolder = "processed_4";
outputFolder = "processed_5";
inputBasepath = fullfile("../Dataset", inputFolder);
outputBasepath= fullfile("../Dataset", outputFolder);
individualPicFolderName = "individual_pic";
individualMovFolderName = "individual_mov";
groupPicFolderName = "group_pic";
groupMovFolderName = "group_mov";

%% Normalization Feature Toggle
shouldAlignEyes = true;
shouldConvertToGrayscale = false;
shouldResizeImages = false;
outputImageSize = [256, 256];
resizeInterpolationMethod = 'bicubic';

%% Create Normalized Image Set Collection with ann individuals pictures
disp("Building ImageSet Collection...");
imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);

%% Iterate over each image performing transformations
disp("Performing image normalization...");
numSets = size(imgSetCollection, 2);
for setIdx=1:numSets
    currentSet = imgSetCollection(setIdx);
    for imgIdx = 1:imgSetCollection(setIdx).Count
        currentImage = read(currentSet, imgIdx);
        
        % Rotate Image to level both eyes
        if(shouldAlignEyes)
            leftEyeDetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye');
            rightEyeDetector = vision.CascadeObjectDetector('ClassificationModel','RightEye');
            leftEyeBox = leftEyeDetector(currentImage);
            rightEyeBox = rightEyeDetector(currentImage);
            
            % Perform rotation only if both eyes were found. Otherwise keep
            % image as is
            if (~isempty(leftEyeBox) && ~isempty(rightEyeBox))
                [leftEye_x, leftEye_y] = CalculateBBoxCenter(leftEyeBox);
                [rightEye_x, rightEye_y] = CalculateBBoxCenter(rightEyeBox);

                delta_w = rightEye_x - leftEye_x;
                delta_h = rightEye_y - leftEye_y;

                theta = atand(delta_h/delta_w);

                currentImage = imrotate(currentImage, -theta, 'bicubic', 'crop');
            end
        end
        % Convert to grayscale
        if (shouldConvertToGrayscale)
            currentImage = rgb2gray(currentImage);
        end
        % Resize image
        if (shouldResizeImages)
            currentImage = imresize(currentImage, outputImageSize, resizeInterpolationMethod);
        end
        
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