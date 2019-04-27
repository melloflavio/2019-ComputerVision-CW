%% Constant definitions
inputPath = "../Dataset\processed_3_cluster_2_pass_2";
outputPath = "../Dataset\processed_3_cluster_2_pass_3_original";

%% Create Image Datastore containing all UNLABELED faces extracted from group data

% Read Folder
groupImgDs = imageDatastore(inputPath, 'IncludeSubfolders', true);

% Establish a SURF feature bag & retrieve features from images
surfFeatureBag = bagOfFeatures(groupImgDs);
groupFeatures = encode(surfFeatureBag, groupImgDs);
%% Cluster Faces
[clusters, C] = kmeans(groupFeatures, 100);

%% Copy Face Images to folders in next step, according to their cluster
for imgIdx = 1:size(clusters, 1)
    currentImage = readimage(groupImgDs, imgIdx);
    clusterId = clusters(imgIdx);
    outFolder = fullfile(outputPath, num2str(clusterId));
    
    imgFile = groupImgDs.Files(imgIdx);
    [~, imageName, imageExt] = fileparts(char(imgFile{1}));
    outFilepath = fullfile(outFolder, strcat(imageName,imageExt));
    mkdir(outFolder); % Ensure folder exists
    imwrite(currentImage, outFilepath);
end

