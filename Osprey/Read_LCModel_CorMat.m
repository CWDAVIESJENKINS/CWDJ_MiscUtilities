function[Output, Overlaps] = Read_LCModel_CorMat(FilePaths, Threshold)
%% function[Output, Overlaps] = Read_LCModel_CorMat(FilePaths, Threshold)
%
% Description: A function for reading correlation matrices from LCModel
% .print files and, if requested, return a list of all metabolites that
% exceed a given threshold (e.g., 0.7).
%
% Input:     FilePaths = A cell array of paths to .PRINT files OR a single
%                       .PRINT filepath OR a path to a folder containing
%                       the .PRINT files.
% Optional:  Threshold = The exclusion threshold. If supplied, only mean 
%                        correlations > threshold are returned.
% Output:    Output = struct containing all correlation matrices, and the
%                      corresponding row and collumn names
%            Overlaps = If Threshold provided, This struct contains a cell 
%                       array of listing all metabolite pairs that exceed 
%                       the stated threshold, along with the mean and
%                       standard deviation of the correlations
%
% C.W. Davies-Jenkins, Johns Hopkins University 2026

if ~iscell(FilePaths) && isfile(FilePaths)
    FilePaths = {FilePaths};
elseif ~iscell(FilePaths) && isfolder(FilePaths)
    List_print = dir(fullfile(FilePaths,'*.print'));
    FilePaths=cell(1,length(List_print));
    for JJ=1:length(List_print)
        FilePaths{JJ} = fullfile(List_print(JJ).folder,List_print(JJ).name);
    end
end

J_Mat = cell(1,length(FilePaths));
J_Row = cell(1,length(FilePaths));
J_Head = cell(1,length(FilePaths));
for JJ=1:length(FilePaths)
    Lines = readlines(FilePaths{JJ});
    
    StartInd = find(contains(Lines,'Correlation coefficients'))+2;
    EndInd = find(contains(Lines,'1000Shift   SDs  delta(1/T2)   SDs        CONC  %SD'))-4;
    
    Lines = Lines(StartInd:EndInd,:);
    
    IsTable = contains(Lines,"0.");
    
    
    %% Extract heading
    Heading = [];
    for KK=1:(find(IsTable,1,'first')-1)
        Temp = strsplit(Lines(KK),' ');
        Temp = Temp(~matches(Temp,""));
        Heading = [Heading,Temp];
    end
    
    %% Extract single-line Values
    StartInd = find(IsTable,1,'first');
    EndInd = find(~IsTable);EndInd = EndInd(StartInd)-1;
    Counter = 1;
    RowName=cell(0);
    Row=cell(0);
    for KK=StartInd:EndInd
        Temp = strsplit(Lines(KK),' ');
        Temp = Temp(~matches(Temp,""));
    
        RowName{Counter} = Temp{1};
        Row{Counter} = Temp(2:end);
    
        Counter = Counter + 1;
    end
    
    %% Extract Multi-line Values
    StartInd = EndInd+2;
    EndInd = find(IsTable,1,'last');
    
    StartLine=[];
    Counter=1;
    for KK=StartInd:EndInd %Ascertain startlines
        Temp = strsplit(Lines(KK),' ');
        Temp = Temp(~matches(Temp,""));
        if ~contains(Temp{1},"0.")
            StartLine(Counter) = KK;
            Counter=Counter+1;
        end
    end
    StartLine(end+1) = find(IsTable,1,'last')+1;
    
    Counter = length(RowName)+1;
    for KK=1:(length(StartLine)-1) %Extract multi-line entries
        Inds = StartLine(KK):(StartLine(KK+1)-1);
        Temp = strsplit(Lines(Inds(1)),' ');
        Temp = Temp(~matches(Temp,""));
        RowName{Counter} = Temp{1};
        Row{Counter} = Temp(2:end);
        for LL=2:length(Inds)
            Temp = strsplit(Lines(Inds(LL)),' ');
            Temp = Temp(~matches(Temp,""));
            Row{Counter} = [Row{Counter},Temp];
        end
        Counter = Counter + 1;
    end
    
    OutMatrix = ones(length(Row{end}))*nan;
    
    %% Construct out matrix
    for KK=1:length(Row)
        for LL=1:length(Row{KK})
            OutMatrix(KK,LL) = str2num(Row{KK}{LL});
        end
    end


    
    J_Mat{JJ} = OutMatrix;
    J_Row{JJ} = RowName;
    J_Head{JJ} = Heading;

end

%% Tidy up
Uniform = true;
S_Mat = size(J_Mat{1});

OutMat = nan(S_Mat(1),S_Mat(2),length(J_Mat));
OutMat(:,:,1) = J_Mat{1};

for JJ=2:length(J_Mat)
    if ~(S_Mat == size(J_Mat{JJ}))
        Uniform = false;
        break
    end
    if ~all(matches(J_Row{1},J_Row{JJ}))
        Uniform = false;
        break
    end
    if ~all(matches(J_Head{1},J_Head{JJ}))
        Uniform = false;
        break
    end
    OutMat(:,:,JJ) = J_Mat{JJ};
end

if Uniform
    Output.Matrix = OutMat;
    Output.x = J_Head{1};
    Output.y = J_Row{1};
else
    Output.Matrix = J_Mat;
    Output.x = J_Head;
    Output.y = J_Row;
end

%% Check for overlaping
if exist("Threshold","var") && Uniform
    [Row, Col] = find(abs(nanmean(OutMat,3))>Threshold);

    Metabs = [J_Head{1}(Col);J_Row{1}(Row)]';
    Overlaps.Name = Metabs;
    Overlaps.Composite = any(contains(Metabs,'+'),2);
    Overlaps.MN = nanmean(OutMat(Row,Col,:),3);
    Overlaps.SD = nanstd(OutMat(Row,Col,:),0,3);
else 
    Overlaps = [];
end

end