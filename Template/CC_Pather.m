function[ProjFolder] = CC_Pather(varargin)
%% function[ProjFolder] = CC_Pather(varargin)
%
% Description: A function to delineate relative paths from standardized
% project folder definitions. This function assumes that the script or
% function from which it is called is contained below a "code" directory
% i.e. code/*anything*/CallingScript.m
%
% Output:    ProjFolder = Absolute path to project folder
% Optional:  varargin = Optional path arguments for constructing sub
%               directory paths
%
% Example usage: 
% For a calling script located here: /Storage/Project1/code/Stuff/Script.m
%
% Folder = CC_Pather;
%       Returns: /Storage/Project1/
%
% Folder2 = CC_Pather('results','experiment1');
%       Returns: /Storage/Project1/results/experiment1
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

PathStack = dbstack('-completenames'); % Find out where this function was called from

if contains(PathStack(end).name,'LiveEditor')       % If called from a script execution, get active filename
    CallingPath = matlab.desktop.editor.getActiveFilename;
    if strcmp(CallingPath(1:8),'untitled')
         error('Called from unsaved file: "%s". CC_Pather must be run from a function (or script, using "run section")',CallingPath)
    end
elseif length(PathStack)==1                         % Elseif only this function in path stack, CC_Pather was called from the command window
    error('Why would you call this from the command window?! CC_Pather must be run from a function (or script, using "run section")')
else                                                % Else, assume we refer to the top calling function
    CallingPath = PathStack(2).file;
end

if contains(lower(CallingPath),'code')              % If "code" is in the path, then try to identify the project directory
    Split = strsplit(CallingPath,filesep);
    Ind = find(contains(lower(Split), 'code'));
    if length(Ind)==1
        Ind = Ind-1;
        ProjFolder = strjoin(Split(1:Ind),filesep);
    elseif isempty(Ind)
        error('Calling script or function is not in a "code" directory: %s', CallingPath)
    else
        error('Multiple references to "code" along full path: %s',CallingPath)
    end
end

if ~isempty(varargin)
    ProjFolder = fullfile(ProjFolder,varargin{:});
end

end