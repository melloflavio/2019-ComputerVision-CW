function [faces, faceCentres] = ExtractFaces(image)
%EXTRACTFACES Extracts all faces from single image and returns the cropped
%face images in a cell array

%% Detect Faces
    faceDetector = vision.CascadeObjectDetector('ClassificationModel','FrontalFaceCART');
    boundingBoxes = faceDetector(image);

%% Crop & return faces as a cell array
    faceCount = size(boundingBoxes,1);
    faces = cell(faceCount, 1);
    faceCentres = zeros(faceCount, 2);
    for bboxIdx = 1:faceCount
        boundingBox = boundingBoxes(bboxIdx, :);
        croppedFace = CropFace(image, boundingBox);
        [centre_x, centre_y] = CalculateBBoxCenter(boundingBox);
        faceCentres(bboxIdx, :) = [centre_x, centre_y];
        faces{bboxIdx} = croppedFace;
    end
    
end

