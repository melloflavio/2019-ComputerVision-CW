function [] = ExtractFrames(folder)
%EXTRACTFRAMES Extracts all frames from all videos in a given folder.
%Outputs the frames as .jpg files in the same folder, using original video
%filename as suffix
%% Constants
    MIN_BRIGHTNESS = 50; % Min brightness to consider image useful & export it
    NTH_FRAME = 5; % Extract every nth frame

%% Extract Frames

    mp4Videos = dir(fullfile(folder, '*.mp4'));
    movVideos = dir(fullfile(folder, '*.mov'));
    allVideos = {mp4Videos.name, movVideos.name};

    for videoIdx = 1:size(allVideos,2)
        videopath = fullfile(folder, allVideos{videoIdx});
        disp(videopath);
        [~, videoname, ~] = fileparts(videopath);
        videoObj = VideoReader(videopath);

        %   Iterate over all frames in video, outputting to jpg every
        %   second frame
        frameIdx = 0;
        while(hasFrame(videoObj))
            if (rem(frameIdx, NTH_FRAME) == 0) % Only take every nth frame
                currentFrame = readFrame(videoObj);
                
                avgBrightness = mean2(rgb2gray(currentFrame));
                if (avgBrightness > MIN_BRIGHTNESS) % If img is too dark, we disconsider it
                    imgFilename = strcat(videoname, "_", int2str(frameIdx), ".jpg");
                    imgPath = fullfile(folder, imgFilename);
                    imwrite(currentFrame, imgPath);
                end
            end
            frameIdx = frameIdx +1;
        end
    end
end
