function [surfFeatures, surfFeatureBag] = ExtractSurfFeatures(imageDatastore)
%EXTRACTSURFFEATURES Extract SURF features from a given datastore

    % Build a feature bag based on the entire dataset
    surfFeatureBag = bagOfFeatures(imageDatastore);
    surfFeatures = encode(imageDatastore, surfFeatureBag);
end

