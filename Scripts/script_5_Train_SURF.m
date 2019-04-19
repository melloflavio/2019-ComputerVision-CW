%% Constant definitions
inputBasepath = "../Dataset\processed_6";

%% Create Normalized Image Set Collection with ann individuals pictures
% imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);
imgDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders',true, 'LabelSource','foldernames');

%% Balance the Datastore wrt label distribution

labelsTable = countEachLabel(imgDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
imgDatastore = splitEachLabel(imgDatastore, minimumSetCount, 'randomized');

%% Split Data into Train/Test - 85/15 ratio

[trainImgDs, testImgDs] = splitEachLabel(imgDatastore, 0.85);

%% Extract SURF features
% Build a feature bag based on training set
surfFeatureBag = bagOfFeatures(trainImgDs);
trainFeatures = encode(trainImgDs, surfFeatureBag);
testFeatures = encode(testImgDs, surfFeatureBag);

% Saves the feature bag. It will be needed later, when encountering
% new images, so that we can extract the same features occurrences
save("../models/surfFeatureBag", 'surfFeatureBag');

%% SVM
% Train
surfSvm = fitcecoc(trainFeatures, trainImgDs.Labels);

predictedSvm = predict(surfSvm, testFeatures);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);

% Save & clear to free memory
save("../models/SVM_SURF", 'surfSvm');
clear(surfSvm);

%% Train Random Forest
numTrees = 700;
surfRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);

predictedRf = predict(surfRf, testFeatures);
confRf = confusionmat(testImgDs.Labels, predictedRf);

% Save & clear to free memory
save("../models/RF_SURF", 'surfRf');
clear(surfRf);

%% Extract HOG features
hogCellSize = [8 8];
hogFeatures = ExtractHogFeatures(imgDatastore, hogCellSize);

save("../models/hogFeatures", 'hogFeatures', 'hogCellSize', '-v7.3');