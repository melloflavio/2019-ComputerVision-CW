%% Constant definitions
inputBasepath = "../Dataset\processed_5";

%% Create Normalized Image Set Collection with ann individuals pictures
imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);

%% Extract SURF features
surfFeatures = bagOfFeatures(imgSetCollection);

%% Extract HOG features
hogCellSize = [8 8];
[hogFeatures, labels, classIndexToLabel] = ExtractHogFeatures(imgSetCollection, hogCellSize);
aceClassifier = fitcecoc(hogFeatures, labels);