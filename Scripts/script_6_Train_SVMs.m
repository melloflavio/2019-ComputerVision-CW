%% Constant definitions
inputBasepath = "../Dataset\processed_5";

%% Create Normalized Image Set Collection with and individuals pictures
imgSetCollection = CreateNormalizedImageSetCollection(inputBasepath);

%% Extract SURF features
surfFeatures = bagOfFeatures(imgSetCollection);

classifierSvmSurf = trainImageCategoryClassifier(peopleImgSets, surfFeatures);





% classdef WeekDays
%    enumeration
%       Monday, Tuesday, Wednesday, Thursday, Friday
%    end
% end
