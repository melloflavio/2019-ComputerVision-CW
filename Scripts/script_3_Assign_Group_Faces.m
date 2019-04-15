%% Constant definitions
inputBasepath = "../Dataset\processed_3";
outputBasepath = "../Dataset\processed_4";
individualPicFolderName = "individual_pic";
individualMovieFolderName = "individual_mov";
groupPicFolderName = "group_pic";
groupMovieFolderName = "group_mov";

groupFolderName = 'group';

%% Get all folders representing each individual
individualFolders = ListSubfolders(inputBasepath);
individualFolders = setdiff(individualFolders , {groupFolderName});  % Remove group folder


%% Iterate over individual people folders creating individual image sets
peopleImgSets = [];
for folderIdx = 1:size(individualFolders,2)
    folderName = individualFolders{folderIdx};
    
    individualImgSet = CreateImageSetFromSubfolders(fullfile(inputBasepath, folderName), folderName);
    fprintf('Building ImageSet for folder %s with %d images\n', folderName, individualImgSet.Count);
    % Store imageset in array containing image sets for each person
    peopleImgSets = [peopleImgSets, individualImgSet];
end

% Based on Lab 05 Code
minimumSetCount = min([peopleImgSets.Count]); % determine the smallest amount of images in a category 

% Use partition method to trim the set to smallest amount
peopleImgSets = partition(peopleImgSets, minimumSetCount, 'randomize');
fprintf('Smallest ImageSet contains %d images, trimming all sets to have equal length\n', minimumSetCount);

%% Create Classifier for sorting faces extracted from group pictures
% No need to partition into train/test sets. All correctly classified
% images are used to reach a better model. Errors in this case are not as
% costly as there will be further human input into checking if faces belong
% to same person
bag = bagOfFeatures(peopleImgSets);
categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

img = imread(fullfile(rootFolder, 'airplanes', 'image_0690.jpg'));
[labelIdx, ~] = predict(categoryClassifier, img);
categoryClassifier.Labels(labelIdx)