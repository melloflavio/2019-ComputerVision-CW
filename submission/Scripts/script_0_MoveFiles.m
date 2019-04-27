%% Constant definitions
basepath = "../Dataset\processed";
picFolderName = "individual_pic";
movieFolderName = "individual_mov";

%% Get all folders
folders = ListSubfolders(basepath);

%% Loop Through all folder
for folderIdx = 1:size(folders,2)
    
    % Resolve paths
    folderName = folders{folderIdx};
    movieFolder = fullfile(basepath, folderName, movieFolderName);
    picFolder = fullfile(basepath, folderName, picFolderName);
    
    fprintf('Processing folder: %s \n', folderName);
    
    % Move movie files
    try
        movefile(fullfile(basepath, folderName, "*.mov"), movieFolder);
    end
    try
        movefile(fullfile(basepath, folderName, "*.mp4"), movieFolder)
    end
    
    % Move picture files
    try
        movefile(fullfile(basepath, folderName, "*.jpeg"), picFolder);
    end
    try
        movefile(fullfile(basepath, folderName, "*.jpg"), picFolder);
    end
end
