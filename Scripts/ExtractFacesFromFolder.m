function [] = ExtractFacesFromFolder(inFolder, outFolder)
%EXTRACTFACESFROMFOLDER Extract all faces from all .jpg images from source
%folder, writing the cropped face images to destination folder. Image
%search is non recursive (i.e. 1 folder deep only)
%   @inFolder: Folder containing images to have faces extracted
%   @outFolder: Folder which should contain all detination images
%   This function leverages ExtractFaces which processes the image &
%   returns the faces. This keeps the image processing and file managing
%   layers separate & independent

    %% Process in/out paths
    allImages = dir(fullfile(inFolder, "*.jpg")); % Get images from inFolder
    mkdir(outFolder); % Ensure outfolder exists to avoid permission issues with imwrite

    %% Iterate over images extracting & saving faces
    for imageIdx = 1:size(allImages,1)
        % Get path components
        imageFolder = allImages(imageIdx).folder;
        imageName = allImages(imageIdx).name;
        imagePath = fullfile(imageFolder, imageName);
        [~, imageNamePlain, ~] = fileparts(imagePath); % Get name without extension
        % Extract faces
        imgObj = imread(imagePath);
        faces = ExtractFaces(imgObj);

        % Save Faces to destination folder
        for faceIdx = 1:size(faces,1)
            faceImg = faces{faceIdx};
            outFilename = strcat(imageNamePlain, "__f_", int2str(faceIdx), ".jpg");
            outFilepath = fullfile(outFolder, outFilename);
            imwrite(faceImg, outFilepath);
        end
    end
end
