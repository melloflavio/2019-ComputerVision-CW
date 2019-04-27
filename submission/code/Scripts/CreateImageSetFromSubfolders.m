function [imageSetCollection] = CreateImageSetFromSubfolders(parentFolder, description)
%CREATEIMAGESETFROMSUBFOLDERS Helper function used to create a single image
%set from images contained in all subfolders (1-level deep) in a parent
%folder. Used in cases where the used wants to sort images belonging to
%classes into parent folders, but keep some sort of subfolder structure for
%record either for record keeping or future flexibility to differentiate
%between image sources
    
    % List subfolders
    subfolders = ListSubfolders(parentFolder);
    
    % generate imageset for each subfolder and accumulate image locations
    imageLocations = {};
    for folderIdx = 1:size(subfolders, 2)
        folderName = subfolders{folderIdx};
        imgSet = imageSet(char(fullfile(parentFolder, folderName)));
        imageLocations = [imageLocations, imgSet.ImageLocation];
    end
    
    imageSetCollection = imageSet(imageLocations);
    imageSetCollection.Description = description;
end

