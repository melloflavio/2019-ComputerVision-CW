%% Load Data (If needed)
load datasets;

%% Extract HOG features
hogCellSize = [8 8];
trainFeatures = ExtractHogFeatures(trainImgDs, hogCellSize);
testFeatures = ExtractHogFeatures(testImgDs, hogCellSize);

%% HOG
% Train
hogSvm = fitcecoc(trainFeatures, trainImgDs.Labels);

% Test
predictedSvm = predict(hogSvm, testFeatures);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);

% Save & clear to free memory
save("../models/SVM_HOG", 'surfHog');
clear(hogSvm);

%% Train Random Forest
numTrees = 700;
hogRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);

predictedRf = predict(hogRf, testFeatures);
confRf = confusionmat(testImgDs.Labels, predictedRf);

% Save & clear to free memory
save("../models/RF_HOG", 'surfRf');
clear(hogRf);
