function [hogFeatures, labels, classIndexToLabel] = ExtractHogFeatures(imageSetCollection, cellSize)
%EXTRACTHOGFEATURES Extracts HOG features from a given normalized ImageSetCollection
%(i.e. Array of ImageSets). It important to ensure the collection is
%normalized both in terms of images per label, and image sizes.
% Based on code provided In Lab06 and https://uk.mathworks.com/help/vision/examples/digit-classification-using-hog-features.html

%% Data sanity check
% Ensures ImageSet is normalized, throws exception otherwise. It is 
% important to ensure the imageset is normalized because the number of 
% images per class is extrapolated from the first dataset to allow for
% array preallocation & speedup
    minimumSetCount = min([imageSetCollection.Count]);
    if(~all([imageSetCollection.Count] == minimumSetCount)) % If any element is
        error('Imageset not normalized');
    end

%% Determine HOG features array size

    % ImageSetCollection dimensions
    numSets = size(imageSetCollection, 2);
    imagesPerSet = imageSetCollection(1).Count;

    sampleImg = read(imageSetCollection(1), 1);
    % Extract HOG features from a sample image to gauge number of HOG features
    [hog_sample, ~] = extractHOGFeatures(sampleImg, 'CellSize', cellSize);
    hogFeaturesPerImg = length(hog_sample);

%% Extract HOG features from all images in all sets

    % Preallocate array
    hogFeatures = zeros(numSets*imagesPerSet, hogFeaturesPerImg);

    % Global image counter as HOG extraction flattens imgsets into a single
    % continuous array
    globalImgIdx = 1;
    for setIdx=1:numSets
        for imgIdx = 1:imagesPerSet
            currentImage = read(imageSetCollection(setIdx), imgIdx);
            hogFeatures(globalImgIdx,:) = extractHOGFeatures(currentImage);
            labels{globalImgIdx} = imageSetCollection(setIdx).Description;
            globalImgIdx = globalImgIdx + 1;
        end
        classIndexToLabel{setIdx} = imageSetCollection(setIdx).Description;
    end

end

