%% Constant definitions
inputBasepath = "../Dataset\processed_6";



%% Extract SURF features
% surfFeatures = bagOfFeatures(imgSetCollection);

% classifierSvmSurf = trainImageCategoryClassifier(peopleImgSets, surfFeatures);

%% Train SURF SVM
% surfSvm = fitcecoc(surfFeatures, surfLabels);
% load("../models/hogFeatures")

hogSvm = fitcecoc(hogFeatures, imgDatastore.Labels);

%% Train HOG SVM


% save("../models/SVM_HOG", 'hogSvm', 'hogCellSize', '-v7.3');

