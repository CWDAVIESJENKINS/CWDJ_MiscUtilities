function [] = CWDJ_SavFig( FigHandle , SavLoc, Size)
%Save a figure as .fig and .pdf at specified location
% Opt:      FigHandle - Figure number of target figure (default=gcf)
%           SavLoc - Path to save figure and pdf with no ext (default=pwd)
%           Size - Size (in inches) of figure units (default=preserves 
%                  current aspect ratio)
%
% Example usage:
%   CWDJ_SavFig(1, /Path/To/Figure, [3, 4]) % Saves Fig.1 at path, with 
%   size of 3x4 inches
%
% C.W.Davies-Jenkins, Johns Hopkins 2022

%% Handle some missing optional variables:
if exist("FigHandle","var")
    FIG=figure(FigHandle);
else
    FIG=gcf;
end
if ~exist('SavLoc','var')
    SavLoc = fullfile(pwd,'CWDJ_Fig');
end

%% Create directory if it doesn't exist:
Dir = fileparts(SavLoc);
if ~exist(Dir,'dir')
    mkdir(Dir);
end

%% Manage size and positioning
set(FIG,'Units','Inches'); % Fix figure units to inches
pos = get(FIG,'Position'); % Get current position of figure

% If figure size not specified, take current dimensions
if ~exist("Size",'var')
    Size = pos(3:4);
end

set(FIG,'PaperSize',Size) % Fix figure paper size as specified


FormatFig(FIG) % some additional formatting for sub figures (seee below)

%% Save 

exportgraphics(FIG,[SavLoc,'.pdf'],'ContentType','vector','BackgroundColor','none') % Print PDF vector format
savefig(FIG,[SavLoc,'.fig'],'compact') % Save figure as .fig

end


function[] = FormatFig(FIG)

AllAxes = findall(FIG,'type','axes');

% For each axis:
%   1) Move ticks outside lines
%   2) Remove outer box
%   3) Set background color to none

for JJ=1:length(AllAxes)
    set(AllAxes(JJ),'TickDir','out','Box','off','color','none');
end
set(FIG, 'color', 'none');

end