function[Out_Table] = DataCompleteness(FileStruct, Visualize)
%% function[Out_Table] = DataCompleteness(FileStruct, Visualize)
%
% Description: A function to generate a report of the completeness of a
% BIDS-compliant dataset. Makes use of the FindFiles data struct. It
% removes subject-level info from filenames and compares unique entries
% across subjects.
%
% Input:     FileStruct = Matlab struct output by the FindFiles function
% Optional:  Visualize = Bool whether to open UI table with highlights
%               (default = true)
% Output:    Out_Table = A table summarizing the found files (by subject)
%
% Example usage:
%               FileStruct = FindFiles('Path/To/BIDS/Directory');
%               Out Table = DataCompleteness(FileStruct);
%
% C.W. Davies-Jenkins, Johns Hopkins University 2024

if ~exist('Visualize','var')
    Visualize = true;
end

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



%% If enabled, visualize the output in a UI table that highlights missing data
if Visualize
    % Establish cells to highlight
    ValBool = Out_Table(1:end-1,2:end)==0; % If a particular file type is not present, highlight
    N = length(Out_Table.Subject)-1;
    TotBool = Out_Table(end,2:end)<N;      % :If the total is less than N, highlight
    [Rows,Cols] = find(table2array([ValBool;TotBool]));
    Cols = Cols+1; % (Exclude first colum (Subject ID)
    
    % Create UI table
    Fig = uifigure('Name', 'Data completeness review', 'Position', [100 100 1600 950]);
    uitbl = uitable(Fig, 'Data', Out_Table, 'Position', [20 20 1560 900]);

    % Apply the highlight style
    warningStyle = uistyle('BackgroundColor',[246, 255, 0]./255, 'FontWeight', 'bold');
    addStyle(uitbl, warningStyle, 'cell', [Rows, Cols]);
end
