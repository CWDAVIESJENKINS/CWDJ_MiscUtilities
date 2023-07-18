function[ProjFolder] = CC_Pather()
%% function[ProjFolder] = CC_Pather()
%
% Description: A function to delineate relative paths from standardized
% project folder definitions. 
%
% Output:    ProjFolder = Absolute path to project folder
% Optional:  Arg1 = 
%
% Example usage: [ProjectFolder] = CC_Pather
%                ResultsPath = fullfile(CC_Pather,'results','MRSFitting');
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

PathStack = dbstack('-completenames'); % Find out where this function was called from

if contains(PathStack(end).name,'LiveEditor')       % If called from a script execution, get active filename
    CallingPath = matlab.desktop.editor.getActiveFilename;
elseif length(PathStack)==1                         % Elseif only this function in path stack, CC_Pather was called from the command window
    error('Why would you call this from the command window?! CC_Pather must be run from a function (or script, using "run section"')
else                                                % Else, assume we refer to the top calling function
    CallingPath = PathStack(end).file;
end

if contains(lower(CallingPath),'code')              % If "code" is in the path, then try to identify the project directory
    Split = strsplit(CallingPath,filesep);
    Ind = find(contains(lower(Split), 'code'));
    if length(Ind)==1
        Ind = Ind-1;
        ProjFolder = strjoin(Split(1:Ind),filesep);
    elseif isempty(Ind)
        error('Calling script/function is not in a "code" directory: %s', CallingPath)
    else
        error('Multiple references to "code" along full path: %s',CallingPath)
    end
end

end