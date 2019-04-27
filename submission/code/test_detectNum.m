inputBasepath = "../Dataset\test_set_numbers\";

%% Generate Datastore
testDatastore = datastore(inputBasepath, 'IncludeSubfolders', true, 'LabelSource','foldernames', 'Type', 'image', 'FileExtensions', {'.jpg', '.jpeg','.mov','.mp4'});

labelsTable = countEachLabel(testDatastore);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
testDatastore = splitEachLabel(testDatastore, minimumSetCount, 'randomized');

numFiles = size(testDatastore.Labels, 1);
%% Run the detection algorithm on all files and calculate performance
correctDetection = logical(zeros(size(testDatastore.Labels))); % Instances in which the correct label is returned among the list
falseDetection = zeros(size(testDatastore.Labels)); % Total number of labels that were incorrectly returned from the list
totalDetection = zeros(size(testDatastore.Labels)); % Total number of labels that were incorrectly returned from the list

for i = 1:numFiles
    % Detect Numbers
    filepath = testDatastore.Files(i);
    detectedNumbers = detectNum(filepath{1});
    
    % Consider success if the label is among the numbers detecte in the
    % image
    detectedNumbers = categorical(detectedNumbers);
    
    correctDetection(i) = any(ismember(testDatastore.Labels(i),detectedNumbers));
    fprintf("predicted: %s - label: %s - result: %s-%d\n", strjoin(string(detectedNumbers), " "), testDatastore.Labels(i), string(correctDetection(i)), size(detectedNumbers, 2));
    falseDetection(i) = size(detectedNumbers, 2) - correctDetection(i);
    totalDetection(i) = size(detectedNumbers, 2);
%     fprintf("predicted: %s - label: %s - result: %s-%d\n", strjoin(string(detectedNumbers), " "), testDatastore.Labels(i), string(correctDetection(i)), falseDetection(i));
end

performance = sum(correctDetection)/numFiles;
falseDetectionRate = sum(falseDetection)/sum(totalDetection);