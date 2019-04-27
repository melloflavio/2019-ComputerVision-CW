inputBasepath = "../Dataset\test_set_numbers";
% inputBasepath = "../Dataset\test_set_numbers\81_2";

% testDatastore = imageDatastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames');
%% Generate Datastore
testDatastore = datastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames', 'Type', 'image', 'FileExtensions', {'.jpg', '.jpeg','.mov','.mp4'});

labelsTable = countEachLabel(testDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
testDatastore = splitEachLabel(testDatastore, minimumSetCount, 'randomized');

%% Split Data into Train/Test - 85/15 ratio

%Take only 30% of the data to test for performance
% [reducedDatastore, ~] = splitEachLabel(testDatastore, 0.50);
reducedDatastore = testDatastore;

numFiles = size(reducedDatastore.Labels, 1);
%% Run the detection algorithm on all files and calculate performance
correctDetection = logical(zeros(size(reducedDatastore.Labels))); % Instances in which the correct label is returned among the list
falseDetection = zeros(size(reducedDatastore.Labels)); % Total number of labels that were incorrectly returned from the list

for i = 1:numFiles
    % Detect Numbers
    filepath = testDatastore.Files(i);
    detectedNumbers = detectNum(filepath{1});
    
    % Consider success if the label is among the numbers detecte in the
    % image
    detectedNumbers = categorical(detectedNumbers);
    
    correctDetection(i) = any(ismember(testDatastore.Labels(i),detectedNumbers));
    falseDetection(i) = size(detectedNumbers, 1) - correctDetection(i);
    fprintf("predicted: %s - label: %s - result: %s\n", strjoin(string(detectedNumbers), " "), testDatastore.Labels(i), string(correctDetection(i)));
end

performance = sum(correctDetection)/numFiles;
falseDetectionRate = sum(falseDetection)/numFiles;