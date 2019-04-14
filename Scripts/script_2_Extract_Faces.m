%% Constant definitions
inputBasepath = "../Dataset\processed";
outputBasepath = "../Dataset\processed_2";
picFolderName = "individual_pic";
movieFolderName = "individual_mov";

%% Get all folders representing each individual
contents = dir(inputBasepath);
folders = {contents([contents.isdir]).name}; % Get only names of dirs
folders = setdiff(folders , {'.', '..'});  % Remove . and .. folder links

%% Iterate over individual people folders extracting faces
for folderIdx = 1:size(folders,2)
    folderName = folders{folderIdx};
    
    fprintf('Processing folder: %s - Movies\n', folderName);
    
    % Extract faces from each Movie folder, output to analogous folder in
    % next pipeline stage
    moviesInput = fullfile(inputBasepath, folderName, movieFolderName);
    moviesOutput = fullfile(outputBasepath, folderName, movieFolderName);
    ExtractFacesFromFolder(moviesInput, moviesOutput);
    
    fprintf('Processing folder: %s - Pictures\n', folderName);
    % Extract faces from each Picture folder, output to analogous folder in
    % next pipeline stage
    picturesInput = fullfile(inputBasepath, folderName, picFolderName);
    picturesOutput = fullfile(outputBasepath, folderName, picFolderName);
    ExtractFacesFromFolder(picturesInput, picturesOutput);
end




