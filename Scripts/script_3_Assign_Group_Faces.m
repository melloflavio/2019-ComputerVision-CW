%% Constant definitions
inputBasepath = "../Dataset\processed_3";
outputBasepath = "../Dataset\processed_4";
individualPicFolderName = "individual_pic";
individualMovFolderName = "individual_mov";
groupPicFolderName = "group_pic";
groupMovFolderName = "group_mov";

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
categoryClassifier = trainImageCategoryClassifier(peopleImgSets, bag);

%% Predict owners for faces from group pictures and copy them to owner's folder in next stage of the pipeline

% Generate separate imagesets for group pictures and frames extracted from group movies data
groupImageSets = [ ...
    imageSet(char(fullfile(inputBasepath, groupFolderName, individualPicFolderName))), ...
    imageSet(char(fullfile(inputBasepath, groupFolderName, individualMovFolderName))) ...
];
groupFolderNames = [groupPicFolderName, groupMovFolderName];

% Predict owner & Write image to her folder in next pipeline stage
for setIdx = 1:size(groupImageSets, 2)
    % Get relevant imageset data
    imgSet = groupImageSets(setIdx);
    subfolderName = groupFolderNames(setIdx);
    
    % Loop through entire imageset
    for imgIdx = 1:imgSet.Count
        % Read the image from imageset
        image = read(imgSet, imgIdx);

        % Predict the face owner's "label" (i.e. her assigned number)
        [labelIdx, ~] = predict(categoryClassifier, image);
        label = string(categoryClassifier.Labels(labelIdx)); % Cast label to string
        

        % Construct destination imagepath for next stage in pipeline. Keeps
        % image name for easier debugging between pipeline stages.
        [~, imageName, imageExt] = fileparts(char(imgSet.ImageLocation(imgIdx)));
        outFolder = fullfile(outputBasepath, label, subfolderName);
        outFilepath = fullfile(outFolder, strcat(imageName,imageExt));
        
        mkdir(outFolder); % Ensure folder exists
        fprintf('Image %s belongs to %s \n', imageName, label);

        % Writes image to next stage in the pipeline
        imwrite(image, outFilepath);
    end
end