function [] = CWDJ_SavFig( FigHandle , SavLoc)
%% function [] = CWDJ_SavFig( FigHandle , SavLoc)
% 
% Function for saving a Matlab figure as .fig and .png at specified location
%
% Optional: FigHandle = Handle of target figure (default=gcf)
%           SavLoc = Path to save figure and pdf with no ext (default=pwd)
%
% Example usage:
% CWDJ_SavFig(1, 'Path/To/Output/Location')
%
% C.W.Davies-Jenkins, Johns Hopkins 2022

% Handle missing variables
if exist("FigHandle","var")
    FIG=figure(FigHandle);
else
    FIG=gcf;
end
if ~exist('SavLoc','var')
    SavLoc = fullfile(pwd,'CWDJ_Fig');
end

Title_PDF = [SavLoc,'.pdf'];
Title_FIG = [SavLoc,'.fig'];

set(FIG,'Units','Inches');
pos = get(FIG,'Position');
set(FIG,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

print(FIG,Title_PDF,'-dpdf','-vector')
savefig(FIG,Title_FIG,'compact')

end