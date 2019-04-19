% Based on VGG Face - MatConvNet by Omkar Parkhi, Elliot Crowley 
% http://www.robots.ox.ac.uk/~vgg/software/vgg_face/
% http://www.vlfeat.org/matconvnet/pretrained/#face-recognition
function [croppedFace] = CropFace(image, boundingBox)
%CROPFACE Crops a square around the center of the bounding box provided
%locating the recognized face.
    epsilon = 0.1; % Used for rounding new box coordinates
    newdim = 224; % Size of new image
    
    %make square
    width = boundingBox(3);
    height = boundingBox(4);

    length = (width + height)/2;

    % Finds center
    centrepoint = [round(boundingBox(1)) + width/2 round(boundingBox(2)) + height/2];
    
    % Calculates boundinbox coordinates, uses epsilon to round towards
    % including the edge pixels
    x1= centrepoint(1) - round((1+epsilon)*length/2);
    y1= centrepoint(2) - round((1+epsilon)*length/2);
    x2= centrepoint(1) + round((1+epsilon)*length/2);
    y2= centrepoint(2) + round((1+epsilon)*length/2);


    % prevent going off the page
    x1= max(1,x1);
    y1= max(1,y1);
    x2= min(x2,size(image,2));
    y2= min(y2,size(image,1));


    image = image(y1:y2,x1:x2,:);
    sizeimg = size(image);
    croppedFace = imresize(image,(newdim/sizeimg(1)));		
end

