%% Constant definitions
inputBasepath = "../Dataset\processed_6";

%% Create Normalized Image Set Collection with ann individuals pictures
imgDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders',true, 'LabelSource','foldernames');
numClasses = numel(categories(imgDatastore.Labels));

labelsTable = countEachLabel(imgDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 

% Use splitEachLabel method to trim the set to smallest amount
imgDatastore = splitEachLabel(imgDatastore, minimumSetCount, 'randomized');

% Split normalized dataset with 70/30 ratio while keeping label proportions
[trainingImages, validationImages] = splitEachLabel(imgDatastore, 0.7, 'randomized');


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
miniBatchSize = 10;
numIterationsPerEpoch = floor(numClasses/miniBatchSize);
options = trainingOptions( ...
    'sgdm',... % Use stochastic gradient descent with momentum optimizer
    'MiniBatchSize',miniBatchSize,... % Learn using mini batches instead of after every datapoint to smooth out learning
    'MaxEpochs',4,... % Specify max epochs to run
    'InitialLearnRate',1e-4,... % Initial Learning rate
    'Verbose',false,... % Omit logs
    'Plots','training-progress',... % Plot progress
    'ValidationData',validationImages,... % Validation set
    'ValidationFrequency',numIterationsPerEpoch ... % Run validation every N steps
);

%% Train Neural Network

faceNet = trainNetwork(trainingImages,layers,options);

%% Test Accuracy

predictedLabels = classify(faceNet, validationImages);

confusionMatrix = confusionmat(validationImages.Labels, predictedLabels);
accuracy = sum(validationImages.Labels == predictedLabels)/size(validationImages.Labels, 1);
fprintf('Accuracy: %d\n', accuracy);

%% Save Neural Network

save("./models/CNN", 'faceNet');