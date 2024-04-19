function[Out_Table] = DataCompleteness(FileStruct)
%% function[Out_Table] = DataCompleteness(FileStruct)
%
% Description: A function to generate a report of the completeness of a
% BIDS-compliant dataset. Makes use of the FindFiles data struct.
%
% Input:     FileStruct = Matlab struct output by the FindFiles function
% Output:    Out_Table = A table summarizing the found files (by subject)
%
% Example usage:
%               FileStruct = FindFiles('Path/To/BIDS/Directory');
%               Out Table = DataCompleteness(FileStruct);
%
% C.W. Davies-Jenkins, Johns Hopkins University 2024


%% Establish the primary fields (subjects & sessions)

Subjects = unique({FileStruct.sub});

if isfield(FileStruct,'ses')
    Sessions = unique({FileStruct.ses});
else
    Sessions=[];
end

%% Remove subject-level info from filenames:

FullPath = {FileStruct.FullPath}';
[~,Files] = fileparts(FullPath);
Files_NS = Files; 

for JJ=1:length(Files)
    Temp = strsplit(Files{JJ},'_');
    Ind = contains(Temp,'sub-');
    Temp(Ind) = [];
    Files_NS{JJ} = strjoin(Temp,'_');
end

UFN = unique(Files_NS); % Unique filenames accross dataset

%% For each subject, check if they have the Unique file name:

for JJ=1:length(Subjects)
    Out{JJ,1} = Subjects{JJ};
    SubFileList = Files_NS(matches({FileStruct.sub},Subjects{JJ}));
    for KK=1:length(UFN)
        Out{JJ,KK+1} = sum(matches(SubFileList,UFN{KK}));
    end
end

%% Create a table to summarize:

Out_Table = cell2table(Out);
Out_Table.Properties.VariableNames = [{'Subject'},UFN'];

% Then, add a line to sum the number of scans:
for JJ=1:length(UFN)
    TotalNumber{JJ} = sum(Out_Table.(UFN{JJ})>0);
end
Out_Table(end+1,:)=[{'Total:'},TotalNumber];



end
