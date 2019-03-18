%% Constant definitions
basepath = "../Dataset\processed";
picFolderName = "individual_pic";
movieFolderName = "individual_mov";

%% Get all folders
contents = dir(basepath)
folders = {contents([contents.isdir]).name}; % Get only names of dirs
folders = setdiff(folders , {'.', '..'});  % Remove . and .. folder links


%% Loop Through all folder
for folderIdx = 1:size(folders,2)
    % Solve
    folderName = folders{folderIdx};
    movieFolder = fullfile(basepath, folderName, movieFolderName);
    picFolder = fullfile(basepath, folderName, picFolderName);
    
    % Move movie files files
    try
        movefile(fullfile(basepath, folderName, "*.mov"), movieFolder);
    end
    try
        movefile(fullfile(basepath, folderName, "*.mp4"), movieFolder)
    end
    
    % Move movie files files
    try
        movefile(fullfile(basepath, folderName, "*.jpeg"), picFolder);
    end
    try
        movefile(fullfile(basepath, folderName, "*.jpg"), picFolder);
    end
end
