function [faces] = ExtractFaces(image)
%EXTRACTFACES Extracts all faces from single image and returns the cropped
%face images in a cell array

%% Detect Faces
    faceDetector = vision.CascadeObjectDetector('ClassificationModel','FrontalFaceCART');
    boundingBoxes = faceDetector(image);

%% Crop & return faces as a cell array
    faceCount = size(boundingBoxes,1);
    faces = cell(faceCount);
    for bboxIdx = 1:faceCount
        boundingBox = boundingBoxes(bboxIdx, :);
        croppedFace = CropFace(imgObj, boundingBox);
        faces{bboxIdx} = croppedFace;
    end
    
end

