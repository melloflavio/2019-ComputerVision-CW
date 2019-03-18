function [] = ExtractFrames(folder)
%EXTRACTFRAMES Extracts all frames from all videos in a given folder.
%Outputs the frames as .jpg files in the same folder, using original video
%filename as suffix
    mp4Videos = dir(fullfile(folder, '*.mp4'));
    movVideos = dir(fullfile(folder, '*.mov'));
    allVideos = {mp4Videos.name, movVideos.name};

    for videoIdx = 1:size(allVideos,2)
        videopath = fullfile(folder, allVideos{videoIdx});
        disp(videopath);
        [~, videoname, ~] = fileparts(videopath);
        videoObj = VideoReader(videopath);

        %   Iterate over all frames in video, outputting to jpg every single
        %   one
        frameIdx = 0;
        while(hasFrame(videoObj))
            currentFrame = readFrame(videoObj);
            imgFilename = strcat(videoname, "_", int2str(frameIdx), ".jpg");
            imgPath = fullfile(folder, imgFilename);
            imwrite(currentFrame, imgPath);
            frameIdx = frameIdx +1;
        end
    end
end
