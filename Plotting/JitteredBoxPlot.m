function[BC] = JitteredBoxPlot(InMat, Colors)
%% function[BC] = JitteredBoxPlot(InMat, Colors)
%
% Description: Plot boxplots alongside scattered individual points.
%
% Input:     InMat = Matrix with columns representing seperate measures
% Optional:  Colors = RGB color vectors, with rows corresponding to the
%            columns of InMat (default uses cbrewer)
% Output:    BC = Boxchar array
%
% Example usage: JitterBoxPlot(DataMatrix, ColorMatrix);
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

%% Manage inputs
S = size(InMat);
if ~exist('Colors','var') || isempty(Colors)
    Colors = cbrewer('qual','Dark2',S(1)); % Use cbrewer function to generate RGB vectors using the "Dark2" set
else
%     ColSize = size(Colors);
%     if ColSize(1)<S(1)
%         error('Color vector is too small (%i, compared to %i matrix columsn)',ColSize,S(1));
%     end
end

%% Define hardcoded paramters

Width = 0.2; % Width of the scatter
Offset = 0.4; % How shifted the scatter is (set to 0 to plot over)

%% Loop and plot

for JJ=1:S(2)
    BC(JJ) = boxchart(JJ*ones(1,S(1)),InMat(:,JJ),'BoxFaceColor',Colors(JJ,:),'MarkerColor',Colors(JJ,:));
    hold on
    Jitter = rand([1,S(1)]).*Width - Width/2 + JJ-Offset;
    plot(Jitter, InMat(:,JJ),'.',"Color",Colors(JJ,:),'MarkerFaceColor',Colors(JJ,:),'MarkerSize',10)
end

xlim([1-2*Offset, JJ+Offset])

Ax = gca;
Ax.XAxis.Visible = 'off'; % remove x-axis

end