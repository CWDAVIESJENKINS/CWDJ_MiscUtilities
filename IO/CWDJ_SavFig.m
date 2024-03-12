function [] = CWDJ_SavFig( FigHandle , SavLoc, Size, OtherFormats)
%Save a figure as .pdf at specified location
% Opt:      FigHandle - Figure number of target figure (default=gcf)
%           SavLoc - Path to save figure and pdf with no ext (default=pwd)
%           Size - Size (in inches) of figure units (default=preserves 
%                  current aspect ratio)
%           OtherFormats - Cellarray of other formats to export using the
%                   "saveas" command (default={'png'})
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
if ~exist("OtherFormats","var")
    OtherFormats = {'png','pdf'};
end

%% Create directory if it doesn't exist:
Dir = fileparts(SavLoc);
if ~exist(Dir,'dir')
    mkdir(Dir);
end

%% Manage size and positioning
set(FIG,'Units','Inches'); % Fix figure units to inches
pos = get(FIG,'Position'); % Get current position of figure

% If figure size not specified, take and scale to current dimensions
if ~exist("Size",'var') || isempty(Size)
    Size = pos(3:4);
end

set(FIG,'PaperSize',Size) % Fix figure paper size as specified
FormatFig(FIG) % some additional formatting for sub figures (seee below)

%% Save 

for JJ=1:length(OtherFormats)
    switch OtherFormats{JJ}
        case 'fig'
            savefig(FIG,[SavLoc,'.fig'],'compact') % Save figure as .fig
        case 'pdf'
            exportgraphics(FIG,[SavLoc,'.pdf'],'ContentType','vector','BackgroundColor','none') % Print PDF vector format
        otherwise
            try
                saveas(FIG,[SavLoc,'.',OtherFormats{JJ}]) %Try to save other format using saveas
            catch
                error('OtherFormat input %i (%s) failed',JJ,OtherFormats{JJ})
            end
    end

end

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