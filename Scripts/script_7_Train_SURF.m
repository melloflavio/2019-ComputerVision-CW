% %% Load Data (If needed)
% load datasets;
% 
% %% Extract SURF feature bag
% % Build a feature bag based on a subset of the training set to avoid memory
% % issues
% [trainBagImgDs, ~] = splitEachLabel(trainImgDs, 0.5, 'randomized');
% 
% disp("Building Feature Bag");
% tic;
% surfFeatureBag = bagOfFeatures(trainBagImgDs);
% fprintf("Done in %f seconds...\n", toc);
% %% Encode Features based on Feature bag
% disp("Encoding Features");
% tic;
% trainFeatures = encode(surfFeatureBag, trainImgDs);
% testFeatures = encode(surfFeatureBag, testImgDs);
% fprintf("Done in %f seconds...\n", toc);
% 
% % Saves the feature bag. It will be needed later, when encountering
% % new images, so that we can extract the same features occurrences
% save("../models/surfFeatureBag", 'surfFeatureBag');
%% Naive Bayes - NB
disp("Training NB...");
tic;
surfNb = fitcnb(trainFeatures, trainImgDs.Labels, 'DistributionNames', 'kernel');
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedNb = predict(surfNb, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
confNb = confusionmat(testImgDs.Labels, predictedNb);
accuracyNb = sum(testImgDs.Labels == predictedNb)/size(predictedNb, 1);
fprintf('Accuracy: %d\n', accuracyNb);

% Save & clear to free memory
save("../results/NB_SURF_CONF", 'confNb');
save("../models/NB_SURF", 'surfNb', '-v7.3');
clear('surfNb');

%% K-Nearest Neighbours - KNN
disp("Training KNN...");
tic;
surfKnn = fitcknn(trainFeatures, trainImgDs.Labels, 'NumNeighbors',5 , 'Standardize', 1);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
tic;
predictedKnn = predict(surfKnn, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
confKnn = confusionmat(testImgDs.Labels, predictedKnn);
accuracyKnn = sum(testImgDs.Labels == predictedKnn)/size(predictedKnn, 1);
fprintf('Accuracy: %d\n', accuracyKnn);

% Save & clear to free memory
save("../results/KNN_SURF_CONF", 'confKnn');
save("../models/KNN_SURF", 'surfKnn', '-v7.3');
clear('surfKnn');

%% Support Vector Machine - SVM
% Train
disp("Training SVM...");
tic;
surfSvm = fitcecoc(trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);
% Test
tic;
predictedSvm = predict(surfSvm, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
predictedSvm = categorical(predictedSvm);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);
accuracySvm = sum(testImgDs.Labels == predictedSvm)/size(predictedSvm, 1);
fprintf('Accuracy: %d\n', accuracySvm);

% Save & clear to free memory
save("../results/SVM_SURF_CONF", 'confSvm');
save("../models/SVM_SURF", 'surfSvm', '-v7.3');
clear('surfSvm');

%% Random Forest - RF
% Train
disp("Training Random Forest...");
tic;
numTrees = 100;
surfRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);
% Test
tic;
predictedRf = predict(surfRf, testFeatures);
fprintf("Predicted in %f seconds...\n", toc);
predictedRf = categorical(predictedRf);
confRf = confusionmat(testImgDs.Labels, predictedRf);
accuracyRf = sum(testImgDs.Labels == predictedRf)/size(predictedRf, 1);
fprintf('Accuracy: %d\n', accuracyRf);

% Save & clear to free memory
save("../results/RF_SURF_CONF", 'confRf');
save("../models/RF_SURF", 'surfRf', '-v7.3');
clear('surfRf');
