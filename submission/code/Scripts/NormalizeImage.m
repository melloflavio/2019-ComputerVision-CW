function [normalizedImage] = NormalizeImage(originalImage)
%NORMALIZEIMAGE Normalizes image to ensure all images have the same
%properties. Performs scaling, rotation and converts to grayscale
%   Detailed explanation goes here
%% Feature Toggle & Settings
shouldAlignEyes = false;
shouldConvertToGrayscale = false;
shouldResizeImages = true;
outputImageSize = [227, 227];
resizeInterpolationMethod = 'bicubic';

    %% Start with original image
    normalizedImage = originalImage;

    %% Rotate Image to level both eyes
    if(shouldAlignEyes)
        leftEyeDetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye');
        rightEyeDetector = vision.CascadeObjectDetector('ClassificationModel','RightEye');
        leftEyeBox = leftEyeDetector(normalizedImage);
        rightEyeBox = rightEyeDetector(normalizedImage);

        % Perform rotation only if both eyes were found. Otherwise keep
        % image as is
        if (~isempty(leftEyeBox) && ~isempty(rightEyeBox))
            [leftEye_x, leftEye_y] = CalculateBBoxCenter(leftEyeBox);
            [rightEye_x, rightEye_y] = CalculateBBoxCenter(rightEyeBox);

            delta_w = rightEye_x - leftEye_x;
            delta_h = rightEye_y - leftEye_y;

            theta = atand(delta_h/delta_w);

            normalizedImage = imrotate(normalizedImage, -theta, 'bicubic', 'crop');
        end
    end

    %% Convert to grayscale
    if (shouldConvertToGrayscale)
        normalizedImage = rgb2gray(normalizedImage);
    end

    %% Resize image
    if (shouldResizeImages)
        normalizedImage = imresize(normalizedImage, outputImageSize, resizeInterpolationMethod);
    end

end

