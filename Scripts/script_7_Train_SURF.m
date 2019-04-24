%% Load Data (If needed)
load datasets;

%% Extract SURF features
% Build a feature bag based on training set
disp("Building Feature Bag");
tic;
surfFeatureBag = bagOfFeatures(trainImgDs);
fprintf("Done in %f seconds...\n", toc);

disp("Encoding Features");
tic;
trainFeatures = encode(surfFeatureBag, trainImgDs);
testFeatures = encode(surfFeatureBag, testImgDs);
fprintf("Done in %f seconds...\n", toc);

% Saves the feature bag. It will be needed later, when encountering
% new images, so that we can extract the same features occurrences
save("../models/surfFeatureBag", 'surfFeatureBag');
%% Naive Bayes - NB
disp("Training NB...");
tic;
surfNb = fitcnb(trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);

% Test
predictedNb = predict(surfNb, testFeatures);
confNb = confusionmat(testImgDs.Labels, predictedNb);
accuracyNb = sum(testImgDs.Labels == predictedNb)/size(predictedNb, 1);
fprintf('Accuracy: %d\n', accuracyNb);

% Save & clear to free memory
save("../results/NB_SURF_CONF", 'confNb');
save("../models/NB_SURF", 'surfNb', '-v7.3');


%% Support Vector Machine - SVM
% Train
disp("Training SVM...");
tic;
surfSvm = fitcecoc(trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);
% Test
predictedSvm = predict(surfSvm, testFeatures);
confSvm = confusionmat(testImgDs.Labels, predictedSvm);
accuracySvm = sum(testFeatures.Labels == predictedSvm)/size(predictedSvm, 1);
fprintf('Accuracy: %d\n', accuracySvm);

% Save & clear to free memory
save("../results/SVM_SURF_CONF", 'confSvm');
save("../models/SVM_SURF", 'surfSvm', '-v7.3');
clear(surfSvm);

%% Random Forest - RF
% Train
disp("Training Random Forest...");
tic;
numTrees = 100;
surfRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);
execTime = toc;
fprintf("Trained in %f seconds...\n", execTime);
% Test
predictedRf = predict(surfRf, testFeatures);
confRf = confusionmat(testImgDs.Labels, predictedRf);
accuracyRf = sum(testFeatures.Labels == predictedRf)/size(predictedRf, 1);
fprintf('Accuracy: %d\n', accuracyRf);

% Save & clear to free memory
save("../results/RF_SURF_CONF", 'confRf');
save("../models/RF_SURF", 'surfRf', '-v7.3');
clear(surfRf);
