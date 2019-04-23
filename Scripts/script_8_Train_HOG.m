%% Load Data (If needed)
% load datasets;

%% Extract HOG features
hogCellSize = [8 8]; % Determine Hog Cell size
trainFeatures = ExtractHogFeatures(trainImgDs, hogCellSize);
testFeatures = ExtractHogFeatures(testImgDs, hogCellSize);

%% HOG
% Train
hogSvm = fitcecoc(trainFeatures, trainImgDs.Labels);

% Test
predictedSvm = predict(hogSvm, testFeatures);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);
accuracySvm = sum(testFeatures.Labels == predictedSvm)/size(predictedSvm, 1);
fprintf('Accuracy: %d\n', accuracySvm);

% Save & clear to free memory
save("../models/SVM_HOG", 'hogSvm');
clear(hogSvm);

%% Train Random Forest
%Train
numTrees = 700;
hogRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);

% Test
predictedRf = predict(hogRf, testFeatures);
confRf = confusionmat(testImgDs.Labels, predictedRf);
accuracyRf = sum(testFeatures.Labels == predictedRf)/size(predictedRf, 1);
fprintf('Accuracy: %d\n', accuracyRf);

% Save & clear to free memory
save("../models/RF_HOG", 'hogRf');
clear(hogRf);
