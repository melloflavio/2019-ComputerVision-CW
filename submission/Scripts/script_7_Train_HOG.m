%% Load Data (If needed)
load datasets;

%% Extract HOG features
disp("Extracting HOG Features...");
hogCellSize = [8 8]; % Determine Hog Cell size
trainFeatures = ExtractHogFeatures(trainImgDs, hogCellSize);
testFeatures = ExtractHogFeatures(testImgDs, hogCellSize);

%% Naive Bayes -  NB
disp("Training NB...");
tic;
hogNb = fitcnb(trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedNb = predict(hogNb, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
confNb = confusionmat(testImgDs.Labels, predictedNb);
accuracyNb = sum(testImgDs.Labels == predictedNb)/size(predictedNb, 1);
fprintf('Accuracy: %d\n', accuracyNb);

% Save & clear to free memory
save("../results/NB_HOG_CONF", 'confNb');
save("../models/NB_HOG", 'hogNb', '-v7.3');
clear('hogNb');

%% K-Nearest Neighbours - KNN
disp("Training KNN...");
tic;
hogKnn = fitcknn(trainFeatures, trainImgDs.Labels, 'NumNeighbors',5 , 'Standardize', 1);
% fitcknn(X,Y,'NumNeighbors',5,'Standardize',1)
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedKnn = predict(hogKnn, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
confKnn = confusionmat(testImgDs.Labels, predictedKnn);
accuracyKnn = sum(testImgDs.Labels == predictedKnn)/size(predictedKnn, 1);
fprintf('Accuracy: %d\n', accuracyKnn);

% Save & clear to free memory
save("../results/KNN_HOG_CONF", 'confKnn');
save("../models/KNN_HOG", 'hogKnn', '-v7.3');
clear('hogKnn');

%% Support Vector Machine - SVM
disp("Training SVM...");
tic;
% Train
hogSvm = fitcecoc(trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedSvm = predict(hogSvm, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);
accuracySvm = sum(testImgDs.Labels == predictedSvm)/size(predictedSvm, 1);
fprintf('Accuracy: %d\n', accuracySvm);

% Save & clear to free memory
save("../results/SVM_HOG_CONF", 'confSvm');
save("../models/SVM_HOG", 'hogSvm', '-v7.3');
clear('hogSvm');

%% Random Forest - RF
%Train
disp("Training Random Forest...");
tic;
numTrees = 100;
hogRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedRf = predict(hogRf, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
predictedRf = categorical(predictedRf);
confRf = confusionmat(testImgDs.Labels, predictedRf);
accuracyRf = sum(testImgDs.Labels == predictedRf)/size(predictedRf, 1);
fprintf('Accuracy: %d\n', accuracyRf);

% Save & clear to free memory
save("../results/RF_HOG_CONF", 'confRf');
save("../models/RF_HOG", 'hogRf', '-v7.3');
clear('hogRf');
