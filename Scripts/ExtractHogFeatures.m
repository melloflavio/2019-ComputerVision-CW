function [hogFeatures] = ExtractHogFeatures(imgDatastore, cellSize)
%EXTRACTHOGFEATURES Extracts HOG features from a given ImageDataStore
% Based on code provided In Lab06 and https://uk.mathworks.com/help/vision/examples/digit-classification-using-hog-features.html

%% Determine HOG features array size

    % ImageSetCollection dimensions
    numImages = size(imgDatastore.Labels, 1);

    sampleImg = readimage(imgDatastore, 1);
    % Extract HOG features from a sample image to gauge number of HOG features
    [hog_sample, ~] = extractHOGFeatures(sampleImg, 'CellSize', cellSize);
    hogFeaturesPerImg = length(hog_sample);

%% Extract HOG features from all images in all sets

    % Preallocate array
    hogFeatures = zeros(numImages, hogFeaturesPerImg);

    % Global image counter as HOG extraction flattens imgsets into a single
    % continuous array
    for imageIdx=1:numImages
        currentImage = readimage(imgDatastore, imageIdx);
        hogFeatures(imageIdx,:) = extractHOGFeatures(currentImage);
    end

end

