function[] = subplot2(Rows,Cols,PlotNum,Margin)
%% function[] = subplot2(Rows,Cols,PlotNum,Margin)
%
% Description: A function which preserves some of the functionality of 
% subplot but adds an addittional argument to specify plot margins.
%
% Input:     Rows = Number of rows in sub-plot grid
%            Cols = Number of columns in sub-plot grid
%            PlotNum = The index of the specific subplot (see subplot)
% Optional:  Margin = Gaps between plots. Either specified as a double
%               (specifiying a common gap between plots and the figure's 
%               edged) or a length-3 vector 
%               (defined: [PlotGapX, PlotGapY, GapAtEdge];)
%
% Example usage: 
%            subplot2(3, 3, 4, [0.03, 0.03, 0])
%   sets a 3x3 grid of plots, creating an axis in the 4th position, i.e.
%   in the 2nd row, 1st collumn, with the inner margins decreased to 0.03,
%   and outer margin removed.
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

if ~exist("Margin","var")
    Margin = [0.05, 0.05, 0.05];
elseif length(Margin)==1
    Margin = Margin.*ones(1,3);
end

LX = (1-(2*Margin(3)+(Cols-1)*Margin(1)))/Cols; %Infer the width of the plot pannels
LY = (1-(2*Margin(3)+(Rows-1)*Margin(2)))/Rows; %Infer the height of the plot pannels


for PlotInd = 1:Rows*Cols % Loop over all pannels
    % Calculate the Column index & x-position of each pannel:
    Rem = mod(PlotInd, Cols);
    if Rem ==0
        ColInd(PlotInd) = Cols;
    else
        ColInd(PlotInd) = Rem;
    end
    XPos = Margin(3) + (ColInd(PlotInd)-1)*Margin(1) + (ColInd(PlotInd)-1)*LX;

    % Calculate row index & y-positiion of each pannel:
    RowInd(PlotInd) = ceil(PlotInd/Cols);
    YPos = 1 - Margin(3) - RowInd(PlotInd)*LY - (RowInd(PlotInd)-1)*Margin(2);
    
    % Pos contains each pannel's bottom-left coordinate:
    Pos(PlotInd,:) = [XPos,YPos];
end

if length(PlotNum)==1
    % If just one PlotNum is specified, then take this with infered pannel size
    PlotPos= [Pos(PlotNum,:),LX,LY];
else
    % Otherwise, multi-pannel sub-plot.
    
    % Take the Pos, RowInd, and ColInd that were specified
    Pos = Pos(PlotNum,:);
    RowInd = RowInd(PlotNum);
    ColInd = ColInd(PlotNum);
    
    % Redefine pannel size by taking the extreme indices:
    ColDiff = max(ColInd)-min(ColInd);
    RowDiff = max(RowInd)-min(RowInd);
    LXext = ColDiff*Margin(1) + (ColDiff+1)*LX;
    LYext = RowDiff*Margin(2) + (RowDiff+1)*LY;
    
    PlotPos = [min(Pos),LXext,LYext];
end

ExistingAxis = findobj('Type', 'axes', 'Position', PlotPos); % Check if there is an existing axis in this location
if isempty(ExistingAxis) % If there isn't, create it
    axes('Position',PlotPos);
else % Otherwise, select it
    axes(ExistingAxis);
end

end

