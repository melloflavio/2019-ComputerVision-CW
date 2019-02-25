NUM_FRAMES_TO_EXTRACT = 5; % Number of frames to extract from video

basePath = "../Dataset\cam group\MOV/";
videoFilenames = [
    "IMG_8224" ...
    "IMG_8225" ...
    "IMG_8226" ...
    "IMG_8228" ...
    "IMG_8229" ...
    "IMG_8230" ...
    "IMG_8231" ...
    "IMG_8232" ...
    "IMG_8233" ...
    "IMG_8235" ...
    "IMG_8236" ...
    "IMG_8237" ...
    "IMG_8240" ...
    "IMG_8241" ...
    "IMG_8243" ...
    "IMG_8244" ...
    "IMG_8245" ...
    "IMG_8246"
    ];
videoExtension = ".mov";

imageExtension = ".jpg";

% Extract frames from each video individually
for vidIdx=1:length(videoFilenames)
    filename = videoFilenames(vidIdx);
    fullPath = strcat(basePath, filename, videoExtension);
    
    % Read video
    videoObj = VideoReader(fullPath);
    totalVideoFrames = videoObj.NumberOfFrames; % Get total number of frames
    fprintf('\n[%s] -  total frames: %d', filename, totalVideoFrames);

    % Get list with indexes of frames to be extracted. Frames are nearly equidistant
    % (rounded down)
    framesToExtract = floor(linspace(0, totalVideoFrames, NUM_FRAMES_TO_EXTRACT));

    %  Re-read video to enable frame iteration after querying total number of
    %  frames
    videoObj = VideoReader(fullPath);

%   Iterate over all frames in video, outputting to jpg only the frames to
%   be extracted
%   Alternative function read(videoObj, frameIndex), which reads only the 
%   exact frame is not recommended per matlab documentation. Thus, 
%   readFrame was used.
    frameIdx = 0;
    while(hasFrame(videoObj))
        currentFrame = readFrame(videoObj);
        if(ismember(frameIdx, framesToExtract))
            fprintf('\n[%s] -  saving frame: %d', filename, frameIdx);
            imgPath = strcat(basePath, filename, "_", string(frameIdx), imageExtension);
            imwrite(currentFrame , imgPath);
        end
        frameIdx = frameIdx +1;
    end
end


    % For each frame index, read that exact frame and output it as .jpg to the same
    % folder as the original video, with frame index as suffix
%     for i = 1:length(framesToExtract)
%         frameIdx = framesToExtract(i);
%         fprintf('\n[%s] -  reading frame: %d', filename, frameIdx);
%         currentFrame = read(videoObj, frameIdx);
%         
%         img_path = strcat(basePath, filename, "_", string(frameIdx), imageExtension);
%         imwrite(currentFrame , img_path);
%     end