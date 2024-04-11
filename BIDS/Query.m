function[FilesOut, ListStruct] = Query(ListStruct,varargin)
%% function[Files] = Query(Files,varargin)
% 
% Function for searching file structures output by FindFiles.m. 
%
% Input:    ListStruct = Struct output by FindFiles.m
%           varargin = Arbitrary-length set of query pairs i.e. the "key" to
%           be queried, followed by the desired "value". Preceding the 
%           value by "~" will search for entries NOT containing that entry 
%           (exclusions) Can also supply an external ListStruct as value, 
%           and match entries (e.g. Participant I.D.).      
% Output:   FilesOut = cell array containing full paths to querried files
%
% Example usage:
% MEGALocations = Query(AllFileStruct,'modality','mrs','seq','megapress','sub',PRESSFileStruct);
%
% C.W. Davies-Jenkins, Johns Hopkins University 2022

if ~(mod(length(varargin),2)==0) % If odd number of arguments supplied:
    error('Must have an even number of varargin. See example usage.')
end

Queries = reshape(varargin,2,length(varargin)/2)'; % Arrange into pairs

for JJ=1:length(varargin)/2
    Key = Queries{JJ,1};
    Value = Queries{JJ,2};

    if ~isfield(ListStruct, Key) % Check this is a field:
        error('%s is not a field of File structure.',Key)
    end
    
    Entries = {ListStruct.(Key)}; %Create cell array containing these entries
    
    if isstruct(Value) % If a struct provided as value, match Files using this key
        if ~isfield(Value, Key) % Check this is a field:
            error('%s is not a field of SECONDARY file structure.',Key)
        end
        [~,Keep] = intersect(Entries, {Value.(Key)}); % Find all files 
    else
        Entries(cellfun(@isnumeric, Entries)) = ''; % Replace empty entries with blank cell
        if ischar(Value) && strcmp(Value(1),'~') % If the search string is preceeded by "~" search for enties that don't have "Value"
            Value = Value(2:end); % Remove "~"
            Keep = ~contains(Entries, Value); % Find entries NOT matching query
        else
            Keep = contains(Entries, Value); % Find entries matching query
        end
        
    end
    ListStruct = ListStruct(Keep); % Keep only files that match the string search
end

FilesOut = {ListStruct.FullPath}; %Output as cell

end