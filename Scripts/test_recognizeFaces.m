% Script used for testing RecognizeFace

%% Determine Image
% imagePath = "../Dataset\test_set\51\individual_pic\IMG_20190128_201924.jpg";
% imagePath = "../Dataset\test_set\65\individual_pic\IMG_20190128_202419.jpg";
% imagePath = "../Dataset\test_set\group\individual_pic\IMG_8224.jpg";
imagePath = "../Dataset\test_set\group\individual_pic\IMG_8241.jpg";
imgObj = imread(imagePath);

%% Select CLassifier Type
% acceptedClassifiers = {'SVM', 'CNN', 'RF', 'NB', 'KNN'};
% acceptedFeatureTypes = {'SURF', 'HOG'};
result = RecogniseFace(imgObj, 'HOG', 'NB');

%% Show image with circles & labels
% Draw Circles around every face
% annotatedImg = insertShape(imgObj, 'circle',[result(:, 2), result(:, 3), ones(size(result, 1), 1)*150], 'LineWidth', 5, 'Color', 'red');
% imshow(annotatedImg);
figure;
imshow(imgObj);

% Add labels to faces
for i = 1:size(result,1)
    text(result(i,2),result(i,3) - 100 ,num2str(result(i,1)), 'Color', 'red', 'HorizontalAlignment', 'center');
end