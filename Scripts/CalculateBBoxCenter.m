function [x_center, y_center] = CalculateBBoxCenter(boundingBox)
%CALCULATEBBOXCENTER Receives a bound box formatted as [x y width height]
%and returns the [x_center y_center] coordinates of the box's center

    x_center = boundingBox(1) + (boundingBox(3)/2); % center = left bound + (width/2)
    y_center = boundingBox(2) + (boundingBox(4)/2); % center = upper bound + (height/2)
    
    % Pixel values are integer
    x_center = round(x_center);
    y_center = round(y_center);
end

