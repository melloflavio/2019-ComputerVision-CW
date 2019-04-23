%% Load Data (If needed)
load datasets;

%% Extract SURF features
% Build a feature bag based on training set
surfFeatureBag = bagOfFeatures(trainImgDs);
trainFeatures = encode(surfFeatureBag, trainImgDs);
testFeatures = encode(surfFeatureBag, testImgDs);

% Saves the feature bag. It will be needed later, when encountering
% new images, so that we can extract the same features occurrences
save("../models/surfFeatureBag", 'surfFeatureBag');

%% SVM
% Train
surfSvm = fitcecoc(trainFeatures, trainImgDs.Labels);

% Test
predictedSvm = predict(surfSvm, testFeatures);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);
accuracySvm = sum(testFeatures.Labels == predictedSvm)/size(predictedSvm, 1);
fprintf('Accuracy: %d\n', accuracySvm);

% Save & clear to free memory
save("../models/SVM_SURF", 'surfSvm');
clear(surfSvm);

%% Train Random Forest
% Train
numTrees = 700;
surfRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);

% Test
predictedRf = predict(surfRf, testFeatures);
confRf = confusionmat(testImgDs.Labels, predictedRf);
accuracyRf = sum(testFeatures.Labels == predictedRf)/size(predictedRf, 1);
fprintf('Accuracy: %d\n', accuracyRf);

% Save & clear to free memory
save("../models/RF_SURF", 'surfRf');
clear(surfRf);
