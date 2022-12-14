function[FilesOut] = Query(Files,varargin)
%% function[Files] = Query(Files,varargin)
% 
% Function for searching file structures output by FindFiles.m. 
%
% Input:    Files = Filestruct output by FindFiles.m
%           varargin = Arbitrary length set of query pairs -- the "key" to
%           be queried, followed by the desired "value".
% Output:   FilesOut = cell array containing full paths to querried files
%
% Example usage:
% MEGALocations = Query(FileStruct,'modality','mrs','seq','megapress');
%
% C.W. Davies-Jenkins, Johns Hopkins University 2022

if ~(mod(length(varargin),2)==0) % If odd number of arguments supplied:
    error('Must have an even number of varargin. See example usage.')
end

Queries = reshape(varargin,2,length(varargin)/2)'; %Arrange queries

for JJ=1:length(varargin)/2   
    if ~isfield(Files, Queries{JJ,1}) % Check this is a field:
        error('%s is not a field of File structure.',Queries{JJ,1})
    end

    % Cell function finds entries not matching query criteria
    Keep = contains({Files.(Queries{JJ,1})}, Queries{JJ,2});
    Files = Files(Keep); % Keep only files that match the string search
end

FilesOut = {Files.FullPath}; %Output as cell

end