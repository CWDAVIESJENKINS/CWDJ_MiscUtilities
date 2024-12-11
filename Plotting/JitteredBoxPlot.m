function[BC] = JitteredBoxPlot(InMat, Colors, varargin)
%% function[BC] = JitteredBoxPlot(InMat, Colors)
%
% Description: Plot boxplots alongside scattered individual points.
%
% Input:     InMat = Matrix with columns representing seperate measures
% Optional:  Colors = RGB color vectors, with rows corresponding to the
%                     columns of InMat (default uses cbrewer)
%            varargin = Additional (pairwise options)
% Output:    BC = Boxchar array
%
% Example usage: JitterBoxPlot(DataMatrix, ColorMatrix);
%
% Additional varargin:
%   Connection = Nx2 vector. Plots links between points specified in the 
%                1st & 2nd colums of each row. Default: []
%   Width = Width of the scatter distribution. Default: 0.2;
%   Offset = How shifted the scatter is, relative to box. Default: 0.4
%   PlotOutliers = Whether to vizualize outliers inline with boxplot.
%                  Default: false.
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

%% Check inputs

% Convert to cell array (if matrix or table)
if ~iscell(InMat) && ~istable(InMat)
    S = size(InMat);
    M=InMat;InMat = cell(1,S(2));
    for JJ=1:S(2)
        InMat{JJ} = M(:,JJ);
    end
elseif istable(InMat)
    keyboard
end

% Create/check color matrix
if ~exist('Colors','var') || isempty(Colors)
    Colors = cbrewer('qual','Dark2',length(InMat),'linear'); % Use cbrewer function to generate RGB vectors using the "Dark2" set
else
    ColSize = size(Colors);
    if ColSize(1)<length(InMat)
        error('Color vector is too small (%i, compared to %i matrix columns)',ColSize,S(1));
    end
end

%% Manage Varargin

%%%%% Inititalize default parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Connection = [];
ConnectionAlpha = 0.4;
Width = 0.2; % Width of the scatter
Offset = 0.35; % How shifted the scatter is (set to 0 to plot over)
PlotOutliers = false;
PointAlpha = 0.5;
PointSize = 25;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Overwrite default parameters, if specified in varargin
if nargin>2
    L = length(varargin)/2;
    Args = reshape(varargin,2,L)';
    for JJ=1:L
        switch Args{JJ,1}
            case "Connection"
                Connection = Args{JJ,2};
            case "ConnectionAlpha"
                ConnectionAlpha = Args{JJ,2};
            case "Width"
                Width = Args{JJ,2};
            case "Offset"
                Offset = Args{JJ,2};
            case "PlotOutliers"
                PlotOutliers = Args{JJ,2};
            case "PointAlpha"
                PointAlpha = Args{JJ,2};
            case "PointSize"
                PointSize = Args{JJ,2};
            otherwise
                warning('Unknown option: %s',Args{JJ,2})
        end
    end
end

%% Loop and plot
for JJ=1:length(InMat)
    if PlotOutliers
        BC(JJ) = boxchart(JJ*ones(1,length(InMat{JJ})),InMat{JJ},'BoxFaceColor',Colors(JJ,:),'MarkerColor',Colors(JJ,:),'BoxWidth',Width);
    else
        BC(JJ) = boxchart(JJ*ones(1,length(InMat{JJ})),InMat{JJ},'BoxFaceColor',Colors(JJ,:),'BoxFaceColor',Colors(JJ,:),'BoxWidth',Width,'MarkerStyle','none');
    end
    hold on
    %rng(abs(floor(sum(InMat{JJ}))));

    Jitter{JJ} = rand([1,length(InMat{JJ})]).*Width - Width/2 + JJ-Offset;

    scatter(Jitter{JJ}, InMat{JJ},'MarkerEdgeColor',Colors(JJ,:),...
                                  'MarkerFaceColor',Colors(JJ,:),...
                                  'MarkerEdgeAlpha',PointAlpha,...
                                  'MarkerFaceAlpha',PointAlpha,...
                                  'SizeData',PointSize);
end

Ax = gca;
Ax.XAxis.Visible = 'off'; % remove x-axis

%% Plot connected points

if ~isempty(Connection)
    Sc = size(Connection);
    for JJ=1:Sc(1)
        L1 = length(Jitter{Connection(JJ,1)});
        L2 = length(Jitter{Connection(JJ,2)});
        if ~(L1 == L2)
            error("Can't plot this connection! Entry %i has different lengths: %i and %i",JJ,L1,L2);
        end
        for KK=1:L1
            plot([Jitter{Connection(JJ,1)}(KK), Jitter{Connection(JJ,2)}(KK)],[InMat{Connection(JJ,1)}(KK), InMat{Connection(JJ,2)}(KK)],'Color',[0,0,0,ConnectionAlpha],'LineWidth',0.2)
        end
    end
end