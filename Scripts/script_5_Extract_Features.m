%% Constant definitions
inputBasepath = "../Dataset\processed_6";

%% Create Normalized Image Set Collection with ann individuals pictures
% imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);
imgDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders',true, 'LabelSource','foldernames');

%% Trim the Datastore to have the same amount of images for each label

labelsTable = countEachLabel(imgDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
imgDatastore = splitEachLabel(imgDatastore, minimumSetCount, 'randomized');

%% Extract SURF features
[surfFeatures, surfLabels, surfFeatureBag] = ExtractSurfFeatures(imageDatastore);
% Saves the feature bag to be used later, when encountering new images so
% that the same features are extracted.
save("surfFeatureBag", 'surfFeatureBag');


%% Extract HOG features
hogCellSize = [8 8];
[hogFeatures, hogLabels, classIndexToLabel] = ExtractHogFeatures(imgSetCollection, hogCellSize);
% save("hogFeatures", 'hogFeatures');
% faceClassifier = fitcecoc(hogFeatures, hogLabels);