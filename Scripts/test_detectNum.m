inputBasepath = "../Dataset\test_set_numbers";

% testDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames');
%% Generate Datastore
testDatastore = datastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames', 'Type', 'image', 'FileExtensions', {'.jpg', '.jpeg','.mov','.mp4'});

labelsTable = countEachLabel(testDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
testDatastore = splitEachLabel(testDatastore, minimumSetCount, 'randomized');

%% Split Data into Train/Test - 85/15 ratio

%Take only 30% of the data to test for performance
[reducedDatastore, ~] = splitEachLabel(testDatastore, 0.50);

numFiles = size(reducedDatastore.Labels, 1);
%%
predictedSuccess = logical(zeros(size(reducedDatastore.Labels)));

for i = 1:numFiles
    % Detect Numbers
    filepath = testDatastore.Files(i);
    detectedNumbers = detectNum(filepath{1});
    
    % Consider success if the label is among the numbers detecte in the
    % image
    detectedNumbers = categorical(detectedNumbers);
    predictedSuccess(i) = any(ismember(testDatastore.Labels(i),detectedNumbers));
    fprintf("predicted: %s - label: %s - result: %s\n", strjoin(string(detectedNumbers), " "), testDatastore.Labels(i), string(predictedSuccess(i)));
end

accuracy = sum(predictedSuccess)/numFiles;