function [imageSetCollection] = CreateNormalizedImageSetCollection(parentFolder)
%CREATEIMAGESETCOLLECTIONWITHFOLDER Creates a collection of image sets
%based on all subfolders (1-level deep) found in a passed parentFolder. A
%single imageset is created for each subfolder found, using 
%CreateImageSetFromSubfolders to aggregate sub-subfolders into a single
%imageset. Imagesets are normalized to ensure all have the same number of
%images
%In practice, this function expects a parentFolder pointing to a complete
%stage of the pipeline, and generates 1 imageSet per person (subfolder),
%while accounting for multiple subfolders per person, as explained in 
%CreateImageSetFromSubfolders

%% Get all folders representing each individual
individualFolders = ListSubfolders(parentFolder);

%% Iterate over individual people folders creating individual image sets
imageSetCollection = [];
for folderIdx = 1:size(individualFolders,2)
    folderName = individualFolders{folderIdx};
    
    individualImgSet = CreateImageSetFromSubfolders(fullfile(parentFolder, folderName), folderName);
%     fprintf('Building ImageSet for folder %s with %d images\n', folderName, individualImgSet.Count);
    % Store imageset in array containing image sets for each person
    imageSetCollection = [imageSetCollection, individualImgSet];
end

% Based on Lab 05 Code
minimumSetCount = min([imageSetCollection.Count]); % determine the smallest amount of images in a category 

% Use partition method to trim the set to smallest amount
imageSetCollection = partition(imageSetCollection, minimumSetCount, 'randomize');
% fprintf('Smallest ImageSet contains %d images, trimming all sets to have equal length\n', minimumSetCount);

end

