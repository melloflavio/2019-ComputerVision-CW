function [subfolders] = ListSubfolders(parentFolder)
%LISTSUBFOLDERS Returns a cell array of strings containing all subfolders
%(1-level deep) of a parent folder
    contents = dir(parentFolder);
    subfolders = {contents([contents.isdir]).name}; % Get only names of dirs
    subfolders = setdiff(subfolders , {'.', '..'});  % Remove . and .. folder links
end

