function [P] = RecogniseFace(I, featureType, classifierName)
%RECOGNISEFACE Summary of this function goes here
%   Detailed explanation goes here
%% Find & Extract faces in image
[faces, faceCentres] = ExtractFaces(I);

%% Classify Faces
    acceptedClassifiers = {'SVM', 'CNN', 'MLP'};
    acceptedFeatureTypes = {'SURF', 'HOG'};
    
    faceOwners = zeros(size(faces,1), 1);
    if (strcmp(classifierName, 'CNN'))
        % Call CNN
        % faceOwners = []
        
    elseif (strcmp(classifierName, 'SVM') && strcmp(featureType, 'SURF'))
        % call SVM - SURF
        % faceOwners = []
    elseif (strcmp(classifierName, 'SVM') && strcmp(featureType, 'HOG'))
        % call SVM - HOG
        % faceOwners = []
    elseif (strcmp(classifierName, 'MLP') && strcmp(featureType, 'SURF'))
        % call MLP - SURF
        % faceOwners = []
    elseif (strcmp(classifierName, 'MLP') && strcmp(featureType, 'HOG'))
        % call MLP - HOG
        % faceOwners = []
    else
        error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
            sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
            sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
        
    end
    
%% Assemble Face Matrix
P = [faceOwners, faceCentres(:, 1), faceCentres(:, 2)];
end

