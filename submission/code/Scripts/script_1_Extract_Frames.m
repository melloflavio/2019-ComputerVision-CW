%% Constant definitions
basepath = "../Dataset\processed";
movieFolderName = "individual_mov";

%% Get all folders representing each individual
folders = ListSubfolders(basepath);


%% Iterate over individual people folders extracting frames
for folderIdx = 1:size(folders,2)
    folderName = folders{folderIdx};
    fprintf('Processing folder: %s \n', folderName);
    movieFolder = fullfile(basepath, folderName, movieFolderName);
    ExtractFrames(movieFolder);
end
