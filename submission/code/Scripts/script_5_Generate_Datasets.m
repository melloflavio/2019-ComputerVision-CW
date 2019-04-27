%% Constant definitions
inputBasepath = "../Dataset\processed_5_half";

%% Create Normalized Image Set Collection with ann individuals pictures
% imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);
imgDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames');

%% Balance the Datastore wrt label distribution

labelsTable = countEachLabel(imgDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
imgDatastore = splitEachLabel(imgDatastore, minimumSetCount, 'randomized');

%% Split Data into Train/Test - 85/15 ratio

[trainImgDs, testImgDs] = splitEachLabel(imgDatastore, 0.85);

%save("datasets", "trainImgDs", "testImgDs");