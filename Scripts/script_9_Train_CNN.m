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
categoriesList = categories(testImgDs.Labels);
predictedCnn = categorical(zeros(size(testImgDs.Labels)));
tic;
for i = 1:size(testImgDs.Labels, 1)
    img = readimage(testImgDs, i);
    prediction = classify(faceNet, img);
    label = categorical(categoriesList(prediction));
    predictedCnn(i) = label;
end
fprintf("Predicted in %f seconds...\n", toc);
confCnn = confusionmat(testImgDs.Labels, predictedCnn_2);
accuracyCnn = sum(testImgDs.Labels == predictedCnn_2)/size(predictedCnn_2, 1);
fprintf('Accuracy: %d\n', accuracyCnn);


%% Save Neural Network

save("../models/CNN", 'faceNet');
save("../models/categoriesList", 'categoriesList');