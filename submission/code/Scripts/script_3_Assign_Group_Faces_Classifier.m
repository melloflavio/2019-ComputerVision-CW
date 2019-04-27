%% Constant definitions
inputBasepathSingle = "../Dataset\processed_2-filtered_single";
inputBasepathGroup = "../Dataset\processed_2";
outputBasepath = "../Dataset\processed_3_1";
individualPicFolderName = "individual_pic";
individualMovFolderName = "individual_mov";
groupPicFolderName = "group_pic";
groupMovFolderName = "group_mov";

groupFolderName = 'group';

%%
peopleImgSets = imageDatastore(inputBasepathSingle, 'IncludeSubfolders', true, 'LabelSource','foldernames');

labelsTable = countEachLabel(peopleImgSets);
minimumSetCount = min(labelsTable.Count); % determine the smallest amount of images in a category 
% Use splitEachLabel method to trim the set to smallest amount
peopleImgSets = splitEachLabel(peopleImgSets, minimumSetCount, 'randomized');
[trainImgDs, testImgDs] = splitEachLabel(peopleImgSets, 0.85);

%% Create Classifier for sorting faces extracted from group pictures
% No need to partition into train/test sets. All correctly classified
% images are used to reach a better model. Errors in this case are not as
% costly as there will be further human input into checking if faces belong
% to same person
surfFeatureBag = bagOfFeatures(trainImgDs);
trainFeatures = encode(surfFeatureBag, trainImgDs);
testFeatures = encode(surfFeatureBag, testImgDs);

%% Train Random Forest
numTrees = 700;
surfRf = TreeBagger(numTrees, trainFeatures, trainImgDs.Labels);
%% Predict owners for faces from group pictures and copy them to owner's folder in next stage of the pipeline

% Generate separate imagesets for group pictures and frames extracted from group movies data
groupImageSets = [ ...
    imageSet(char(fullfile(inputBasepathGroup, groupFolderName, individualPicFolderName))), ...
    imageSet(char(fullfile(inputBasepathGroup, groupFolderName, individualMovFolderName))) ...
];
groupFolderNames = [groupPicFolderName, groupMovFolderName];

% Predict owner & Write image to her folder in next pipeline stage
for setIdx = 1:size(groupImageSets, 2)
    % Get relevant imageset data
    imgSet = groupImageSets(setIdx);
    subfolderName = groupFolderNames(setIdx);
    
    % Loop through entire imageset
    for imgIdx = 1:(imgSet.Count)
        % Read the image from imageset
        image = read(imgSet, imgIdx);
        imageFeatures = encode(surfFeatureBag, image);
        % Predict the face owner's "label" (i.e. her assigned number)
        [label, score] = predict(surfRf, imageFeatures);
        label = label{1};
%         hofFeatures = extractHOGFeatures(image, 'CellSize', [8 8]);
%         [labelIdx_hog, score_hog] = predict(hogSvm, hofFeatures);
%         
%         [labelIdx_hog_rf, score_hog_rf] = predict(hogRf, hofFeatures);
        
%         label = string(categoryClassifier.Labels(labelIdx)); % Cast label to string
%         label_hog = string(categoryClassifier.Labels(labelIdx_hog)); % Cast label to string
%         label_hog_rf = labelIdx_hog_rf{1};
%         label_hog_rf = string(categoryClassifier.Labels(labelIdx_hog_rf{1})); % Cast label to string
        

        % Construct destination imagepath for next stage in pipeline. Keeps
        % image name for easier debugging between pipeline stages.
        [~, imageName, imageExt] = fileparts(char(imgSet.ImageLocation(imgIdx)));
        if(max(score) > 0.35)
            outFolder = fullfile(outputBasepath, label, subfolderName);
        else
            outFolder = fullfile(outputBasepath, 'group', subfolderName);
        end
        
        outFilepath = fullfile(outFolder, strcat(imageName,imageExt));
        
        mkdir(outFolder); % Ensure folder exists
        fprintf('Image %s belongs to %s - %f\n', imageName, label, max(score));
%         disp(max(score));

        % Writes image to next stage in the pipeline
        imwrite(image, outFilepath);
    end
end