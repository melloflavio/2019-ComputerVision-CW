function [P] = RecogniseFace(I, featureType, classifierName)
%RECOGNISEFACE Summary of this function goes here
%   Detailed explanation goes here
    %% Find & Extract faces in image
    [faces, faceCentres] = ExtractFaces(I);

    
    if (isempty(faces)) % If no faces found return empty matrix
        P = [];
    else % Classify Faces
        acceptedClassifiers = {'SVM', 'CNN', 'RF', 'NB', 'KNN'};
        acceptedFeatureTypes = {'SURF', 'HOG'};

        faceOwners = categorical(zeros(size(faces)));
        if (strcmp(classifierName, 'CNN'))
            % Load CNN
            cnnModel = load("../models/CNN");
            faceNet = cnnModel.faceNet;
            faceOwners = classify(faceNet, faces);
            % Predict faces individually due to limitations in GPU memory
            for i = 1:size(faces,1)
                currentFace = faces(i);
                prediction = classify(faceNet, currentFace);
                % NN prediction is a number representing the neuron with
                % maximum softmax score. We need to translate this number into
                % the category name (i.e. the label number assigned to the
                % predicted person)
                label = categorical(categoriesList(prediction)); 
                faceOwners(i) = label;
            end
        elseif (strcmp(featureType, 'SURF'))
            % Load feature bag & extract features from detects faces
            surfFeatureBag = load("../models/surfFeatureBag");
            faceFeatures = encode(faces, surfFeatureBag);

            % Load user selected model & predict faces
            if(strcmp(classifierName, 'NB'))
                model = load("../models/NB_SURF");
                faceOwners = predict(model.surfNb, faceFeatures);
            elseif(strcmp(classifierName, 'KNN'))
                model = load("../models/KNN_SURF");
                faceOwners = predict(model.surfKnn, faceFeatures);
            elseif(strcmp(classifierName, 'SVM'))
                model = load("../models/SVM_SURF");
                faceOwners = predict(model.surfSvm, faceFeatures);
            elseif(strcmp(classifierName, 'RF'))
                model = load("../models/RF_SURF");
                faceOwners = predict(model.surfRf, faceFeatures);
            
            else % Model combination not found
                error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
                sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
                sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
            end


        elseif (strcmp(featureType, 'HOG'))
            numFaces = size(faces, 1);
            cellSize = [8 8];
            [hog_sample, ~] = extractHOGFeatures(faces(1), 'CellSize', cellSize);
            hogFeaturesPerImg = length(hog_sample);
            % Preallocate array
            faceFeatures = zeros(numFaces, hogFeaturesPerImg);

            % Extract HOG features for each individual image
            for imageIdx=1:numFaces
                currentImage = readimage(imgDatastore, imageIdx);
                currentFeatures = extractHOGFeatures(currentImage, 'CellSize', cellSize);
                faceFeatures(imageIdx,:) = currentFeatures;
            end

            % Load user selected model & predict faces
            if(strcmp(classifierName, 'NB'))
                model = load("../models/NB_HOG");
                faceOwners = predict(model.hogNb, faceFeatures);
            elseif(strcmp(classifierName, 'KNN'))
                model = load("../models/KNN_HOG");
                faceOwners = predict(model.hogKnn, faceFeatures);
            elseif(strcmp(classifierName, 'SVM'))
                model = load("../models/SVM_HOG");
                faceOwners = predict(model.hogSvm, faceFeatures);
            elseif(strcmp(classifierName, 'RF'))
                model = load("../models/RF_HOG");
                faceOwners = predict(model.hogRf, faceFeatures);
            
            else % Model combination not found
                error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
                sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
                sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
            end
       
        else % Model combination not found
            error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
                sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
                sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
        end

    %% Assemble Face Matrix
        P = [faceOwners, faceCentres(:, 1), faceCentres(:, 2)];
    end 
end

