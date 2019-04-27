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
            % Clear GPU & wait for clearing to complete
            reset(gpuDevice(1));
            wait(gpuDevice(1)); 
            
            % Load CNN
            cnnModel = load("../models/CNN");
            faceNet = cnnModel.faceNet;
            
            % Converts cell array to 4-D array & predict owners
            facesArray = cat(4, faces{:}); 
            faceOwners = classify(faceNet, facesArray);
            
%             categoriesList = load("../models/categoriesList");
%             categoriesList = categoriesList.categoriesList;
%             % Predict faces individually due to limitations in GPU memory
%             for i = 1:size(faces,1)
%                 currentFace = faces{i};
%                 prediction = classify(faceNet, currentFace);
%                 % NN prediction is a number representing the neuron with
%                 % maximum softmax score. We need to translate this number into
%                 % the category name (i.e. the label number assigned to the
%                 % predicted person)
%                 label = categorical(categoriesList(prediction)); 
%                 faceOwners(i) = label;
%             end
        elseif (strcmp(featureType, 'SURF'))
            % Load feature bag & extract features from detects faces
            surfFeatureBag = load("../models/surfFeatureBag");
            surfFeatureBag = surfFeatureBag.surfFeatureBag;
            facesFeatures = [];
%             facesFeatures = encode(surfFeatureBag, faces);
            for i = 1:size(faces,1)
                currentFace = faces{i};
                currentFeatures = encode(surfFeatureBag, currentFace);
                facesFeatures = [facesFeatures; currentFeatures];
            end

            % Load user selected model & predict faces
            if(strcmp(classifierName, 'NB'))
                model = load("../models/NB_SURF");
                faceOwners = predict(model.surfNb, facesFeatures);
            elseif(strcmp(classifierName, 'KNN'))
                model = load("../models/KNN_SURF");
                faceOwners = predict(model.surfKnn, facesFeatures);
            elseif(strcmp(classifierName, 'SVM'))
                model = load("../models/SVM_SURF");
                faceOwners = predict(model.surfSvm, facesFeatures);
            elseif(strcmp(classifierName, 'RF'))
                model = load("../models/RF_SURF");
                faceOwners = predict(model.surfRf, facesFeatures);
            
            else % Model combination not found
                error(sprintf(strcat('Classifier and feature type combination not found.', '\n', ...
                sprintf('Accepted classifiers: %s', strjoin(acceptedClassifiers, ' ')), '\n', ...
                sprintf('Accepted feature types: %s', strjoin(acceptedFeatureTypes, ' ')), '\n')));
            end


        elseif (strcmp(featureType, 'HOG'))
            numFaces = size(faces, 1);
            cellSize = [8 8];
            [hog_sample, ~] = extractHOGFeatures(faces{1}, 'CellSize', cellSize);
            hogFeaturesPerImg = length(hog_sample);
            % Preallocate array
            facesFeatures = zeros(numFaces, hogFeaturesPerImg);

            % Extract HOG features for each individual image
            for i=1:numFaces
                currentFace = faces{i};
                currentFeatures = extractHOGFeatures(currentFace, 'CellSize', cellSize);
                facesFeatures(i,:) = currentFeatures;
            end

            % Load user selected model & predict faces
            if(strcmp(classifierName, 'NB'))
                model = load("../models/NB_HOG");
                faceOwners = predict(model.hogNb, facesFeatures);
            elseif(strcmp(classifierName, 'KNN'))
                model = load("../models/KNN_HOG");
                faceOwners = predict(model.hogKnn, facesFeatures);
            elseif(strcmp(classifierName, 'SVM'))
                model = load("../models/SVM_HOG");
                faceOwners = predict(model.hogSvm, facesFeatures);
            elseif(strcmp(classifierName, 'RF'))
                model = load("../models/RF_HOG");
                faceOwners = predict(model.hogRf, facesFeatures);
            
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
    %% Filter out faces detected as 'non face' from the results array
        non_faces = faceOwners == categorical({'non_faces'});
%         faceOwners = faceOwners(~non_faces);
% 
%         faces_x = faceCentres(:, 1);
%         faces_y = faceCentres(:, 2);
%         
%         faces_x = faces_x(~non_faces);
%         faces_y = faces_y(~non_faces); 

        faceOwners(non_faces) = categorical({'-1'});
        faceOwners = faceOwners(non_faces);

        faces_x = faceCentres(:, 1);
        faces_y = faceCentres(:, 2);
        
        faces_x = faces_x(non_faces);
        faces_y = faces_y(non_faces); 
        
    %% Assemble Face Matrix
        % Convert face owners from categorical label to numerical value
        faceNums = str2num(char(faceOwners));
        
        % Assemble matrix
        P = [faceNums, faces_x, faces_y];

    end 
end

