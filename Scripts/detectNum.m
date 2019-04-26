function [detectedNumbers] = detectNum(filename)
%DETECTNUM Detects Numbers present in an image or video
    [~, ~, extension] = fileparts(char(filename)); % get file extension

    detectedNumbers = [];
    % Detect media type from file extension
    if (strcmp(extension, ".jpg") || strcmp(extension, ".jpeg")) % Picture
        colorImage = imread(filename); % Read image
        detectedNumbers = ExtractNumbersFromFrame(colorImage); % Detect numbers
    elseif (strcmp(extension, ".mp4")) % Movie
        videoObj = VideoReader(filename); 
        %   Iterate over all frames in video, detecting all the numbers in
        %   each frame, accumulating all detected numbers in an array &
        %   shrinking array to store only unique numbers found
        frameIdx = 0;
        while(hasFrame(videoObj))
            disp(frameIdx);
%             if (frameIdx > 55)
%                 figure;
%                 imshow(currentFrame);
%             end
            currentFrame = readFrame(videoObj); % Read frame
            frameNumbers = ExtractNumbersFromFrame(currentFrame); % Detect numbers

            detectedNumbers = [detectedNumbers, frameNumbers]; % Accumulate 
            detectedNumbers = unique(detectedNumbers); % Shrink
            frameIdx = frameIdx +1;
        end
    else
        error("Media type not supported. Supported extensions are: .jpg, .jpeg, .mp4");
    end
end

