function[Files, FlaggedFiles] = FindFiles(TopDIR,Exts)
%% function[Files, FlaggedFiles] = FindFiles(TopDIR,Exts)
% 
% Function that recursively searches TopDIR for files with extensions
% matching Exts{}. Then, exploiting the folder/file naming conventions of
% BIDS, it will output a struct of file locations and information.The 
% Prefix, suffix and key-value pairs of filenames are procedurally placed
% into the struct. This allows filtering of files using this information
% using the companion script: Query.m
%
% Additonally, warnigs are produced for potential BIDS convention
% inconsitencies within the data folder.
% 
% NOTE: Currently assumes no acqustion-level folders
%
% Input:    TopDIR = Top-level dirctory to begin search
%           Exts = Cell array of extensions (default={'.nii*'} nii & nii.gz)
% Output:   Files = Structure containing file paths and information
%           FlaggedFiles = Cell array of potentially BIDS-conflicting paths
%
% Example usage:
% Files = Query('Path/to/my/data',{'.nii*','.SDAT'});
%       - This searches for nii, nii.gz, and sdat files
%       - The 'data' folder has the sub-directory structure of BIDS
%
% C.W. Davies-Jenkins, Johns Hopkins University 2022

if ~exist('Exts','var')
    Exts = {'.nii*'}; % Search for .nii & .nii.gz
elseif isstring(Exts)
    Exts = {Exts}; % If single ext, place in cell
end

%% Find files matching extensions
% Initialize lists
Filelist = [];
Folderlist = [];

for JJ=1:length(Exts) % Run through extensions and iteratively add entries to lists
    DIR = dir(fullfile(TopDIR,'**',['*',Exts{JJ}])); % Recursive search for each extension
    Folderlist = [Folderlist; {DIR.folder}']; % Cell array of folder names
    Filelist = [Filelist;{DIR.name}']; % Cell array of file names
end

L=length(Filelist);
Files = repmat(struct(), L, 1 ); % pre-alocate files struct
FlaggedFiles = cell(0);

for JJ = 1:L %Loop over all files
    ProbFlag=0;
    %% Extract info from file names
    Files(JJ).FullPath = [Folderlist{JJ},filesep,Filelist{JJ}]; % Generate full path
    [~,FileNoExt,Ext1]=fileparts(Filelist{JJ});[~,FileNoExt,Ext2]=fileparts(FileNoExt); % Run this twice to catch .nii.gz etc.
    Files(JJ).Ext = [Ext1,Ext2]; % Add both extensions to Files struct
    FileLevels = strsplit(FileNoExt,'_'); % Define file levels, sepparated using '_' as delim
    for KK = 1:length(FileLevels) %loop over levels
        if KK==1 && ~contains(FileLevels{KK},'-') % If Prefix:
            Files(JJ).prefix = FileLevels{KK};
        elseif contains(FileLevels{KK},'-') % If key-value pair:
            KVP = strsplit(FileLevels{KK},'-');
            Files(JJ).(KVP{1}) = KVP{2};
        elseif KK==length(FileLevels) && ~contains(FileLevels{KK},'-') % If suffix:
            Files(JJ).suffix = FileLevels{KK};
        else % Else we have an issue with filename.
            warning('Caution! Incorrect BIDs filename syntax (prefix_key1-value1_key2-value2_..._suffix.ext):n%s',FileNoExt);
            ProbFlag=1;
        end
    end
    
    %% Extract info from directory structure 
    % Add modality info and check for file/folder name consistency at sub/ses level

    FolderLevels = strsplit(erase(Folderlist{JJ},TopDIR),filesep); % Look at folder levels below specified TopDIR
    if isempty(FolderLevels{1}) % 1st entry may be empty depending on trailing filesep
        FolderLevels = FolderLevels(2:end);
    end
    % Sub, ses, and modality entries assume: 
    %   sub-* at the level below TopDIR
    %   optional ses-* below sub
    %   Then modality (e.g. mrs or anat etc.) below this
    %   Outputs a warning if additional folder layers detected beyond this
    Sub = erase(FolderLevels{1},'sub-'); % Assume Subject at top level
    if contains(FolderLevels{2},'ses-') % If there is a session level, add it
        Ses = erase(FolderLevels{2},'ses-');
        N=3;
    else % If no session level, leave empty
        Ses = [];
        N=2;
    end
    Files(JJ).modality = FolderLevels{N}; % 'modality' occurs at next directory level
    
    if length(FolderLevels)>N+1
        % There may be one level below 'modality' depending on format
        warning('Deep folder levels detected:\n%s\n',fullfile(Folderlist{JJ},Filelist{JJ}))
        ProbFlag=1;
    end

    %Check for BIDS filename inconsistencies and throw warnings:
    if ~strcmp(Sub,Files(JJ).sub)
        warning('Potential file/folder name inconsistency detected! Subject mismatch:\n%s\n',fullfile(Folderlist{JJ},Filelist{JJ}))
        ProbFlag=1;
    end
    if xor(~isempty(Ses), isfield(Files(JJ),'ses') && ~isempty(Files(JJ).ses))
        warning('Potential file/folder name inconsistency detected! Session tag missing:\n%s\n',fullfile(Folderlist{JJ},Filelist{JJ}))
        ProbFlag=1;
    elseif isfield(Files(JJ), 'ses') && ~strcmp(Files(JJ).ses,Ses)
        warning('Potential file/folder name inconsistency detected! Session mismatch:\n%s\n',fullfile(Folderlist{JJ},Filelist{JJ}))
        ProbFlag=1;
    end

    if ProbFlag % If particular file is flagged, add it to a list
        FlaggedFiles = [FlaggedFiles,fullfile(Folderlist{JJ},Filelist{JJ})];
    end

end

end