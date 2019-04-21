function [P] = RecogniseFace(I, featureType, classifierName)
%RECOGNISEFACE Summary of this function goes here
%   Detailed explanation goes here
%% Find & Extract faces in image
[faces, faceCentres] = ExtractFaces(I);

%% Classify Faces
    acceptedClassifiers = {'SVM', 'CNN', 'RF'};
    acceptedFeatureTypes = {'SURF', 'HOG'};
    
    faceOwners = zeros(size(faces,1), 1);
    if (strcmp(classifierName, 'CNN'))
        faceNet = load("../models/CNN");
        faceOwners = classify(faceNet, faces);
    elseif (strcmp(classifierName, 'SVM') && strcmp(featureType, 'SURF'))
        surfSvm = load("../models/SVM_SURF");
        surfFeatureBag = load("../models/surfFeatureBag");
        faceFeatures = encode(faces, surfFeatureBag);
        faceOwners = predict(surfSvm, faceFeatures);
    elseif (strcmp(classifierName, 'SVM') && strcmp(featureType, 'HOG'))
        hogSvm = load("../models/SVM_HOG");
        faceOwners = predict(hogSvm, faces);
    elseif (strcmp(classifierName, 'RF') && strcmp(featureType, 'SURF'))
        surfRf = load("../models/RF_SURF");
        faceOwners = predict(surfRf, faces);
    elseif (strcmp(classifierName, 'RF') && strcmp(featureType, 'HOG'))
        hogRf = load("../models/RF_HOG");
        surfFeatureBag = load("../models/surfFeatureBag");
        faceFeatures = encode(faces, surfFeatureBag);
        faceOwners = predict(hogRf, faceFeatures);
    else
        error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
            sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
            sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
        
    end
    
%% Assemble Face Matrix
P = [faceOwners, faceCentres(:, 1), faceCentres(:, 2)];
end

