%% Load Data (If needed)
load datasets;

%% Determine Data Dimension

numClasses = size(categories(trainImgDs.Labels), 1);

%% Setup Neural Network

% Based on Slides on Lecture 07
alexNet = alexnet; % Load Pretrained Network
% Keep only initial layers regarding with pretrained features / remove last
% section which is domain specific and does the classification based on
% features learned/extracted in initial layers
layersTransfer = alexNet.Layers(1:end-3);
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer
];
miniBatchSize = 5;
numIterationsPerEpoch = floor(numClasses/miniBatchSize);
options = trainingOptions( ...
    'sgdm',... % Use stochastic gradient descent with momentum optimizer
    'MiniBatchSize',miniBatchSize,... % Learn using mini batches instead of after every datapoint to smooth out learning
    'MaxEpochs',4,... % Specify max epochs to run
    'InitialLearnRate',1e-4,... % Initial Learning rate
    'Verbose',false,... % Omit logs
    'Plots','training-progress',... % Plot progress
    'ValidationData',testImgDs,... % Validation set
    'ValidationFrequency',numIterationsPerEpoch ... % Run validation every N steps
);

%% Train Neural Network

faceNet = trainNetwork(trainImgDs, layers, options);

%% Test Accuracy

tic;
predictedCnn = classify(faceNet, testImgDs);
fprintf("Predicted in %f seconds...\n", toc);
confCnn = confusionmat(testImgDs.Labels, predictedCnn);
accuracyCnn = sum(testImgDs.Labels == predictedCnn)/size(predictedCnn, 1);
fprintf('Accuracy: %d\n', accuracyCnn);


%% Save Neural Network

save("../results/CNN_CONF", 'confCnn');
save("../models/CNN", 'faceNet');
save("../models/categoriesList", 'categoriesList');