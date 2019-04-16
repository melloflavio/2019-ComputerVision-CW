function [surfFeatures, labels, surfFeatureBag] = ExtractSurfFeatures(imageDatastore)
%EXTRACTSURFFEATURES Summary of this function goes here
%   Detailed explanation goes here

    % Build a feature bag based on the entire dataset
    surfFeatureBag = bagOfFeatures(imageDatastore);
    
    surfFeatures = encode(imageDatastore, surfFeatureBag);
    labels = imageDatastore.Labels;
%     % Global image counter as HOG extraction flattens imgsets into a single
%     % continuous array
%     numImages = size(imageDatastore.Labels, 1);
%     
%     for imgIdx =  1:numImages
%         currentImage = read(imageDatastore, imgIdx);
%         surfFeatures(imgIdx,:) = encode(currentImage);
%         labels{imgIdx} = imageDatastore.Labels(setIdx);
% %         classIndexToLabel{setIdx} = imageDatastore(setIdx).Description;
%     end
%     
% 

end

