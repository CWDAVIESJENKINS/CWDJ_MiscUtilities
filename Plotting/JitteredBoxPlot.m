function[BC, Output] = JitteredBoxPlot(InMat, Colors, varargin)
%% function[BC] = JitteredBoxPlot(InMat, Colors)
%
% Description: Plot boxplots alongside scattered individual points.
%
% Input:     InMat = Matrix with columns representing seperate measures or
%               a cell array of vectors
% Optional:  Colors = RGB color vectors, with rows corresponding to the
%               columns of InMat (default uses cbrewer)
%            varargin = Additional (pairwise options)
% Output:    BC = Boxchar array
%            Output = A struct containing the median, quartiles, outliers,
%               and whisker locations for each input dataset.
%
% Example usage: JitterBoxPlot(DataMatrix, ColorMatrix);
%
% Additional varargin:
%   Connection = Nx2 vector. Plots links between points specified in the 
%                1st & 2nd colums of each row. Default: []
%   ConnectionAlpha = Transparency of the connecting lines. Default = false
%   Width = Width of the scatter distribution. Default: 0.2
%   Offset = How shifted the scatter is, relative to box. Default: 0.4
%   PointAlpha = Transparency of data points. Default: 0.5
%   PointSize = Size of data points. Default: 25
%   PlotOutliers = Whether to vizualize outliers inline with boxplot.
%                  Default: false.
%   PointShape = shape of scatter points. Default: {'o','o','o',...}
%   Xlabels    = Cell of x-axis labels. Default: []
%   Signif     = Nx3 vector. Adds annotations of signifcance between 
%                boxplot N(1) and N(2), with p-val N(3).
%   SignifAlph = Vector of increasing alpha levels. SignifAlph(N) adds N
%                stars.
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023

%% Check inputs

% Convert to cell array (if matrix or table)
if istable(InMat)
    keyboard     % <- TODO
elseif iscell(InMat)
    S = length(InMat);
else
    S = size(InMat);
    M=InMat;InMat = cell(1,S(2));
    for JJ=1:S(2)
        InMat{JJ} = M(:,JJ);
    end
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
Connection = [];                        % Array defining group connections
ConnectionAlpha = 0.4;                  % Alpha of the connecting lines
Width = 0.2;                            % Width of the scatter
Offset = 0.35;                          % How shifted the scatter is (set to 0 to plot over)
PlotOutliers = false;                   % Bool—whether to to plot outliers in boxchart
PointAlpha = 0.5;                       % Alpha of the scatter points
PointSize = 25;                         % Size of the scatter points
PointShape = repmat({'o'},S(2),1);      % Shape of scatter point (cell array)
Xlabels = [];                           % Cell of xlabels
Signif = [];                            % Array defining significance annotations
SignifAlph = [0.05, 0.005, 0.0005];     % Array defining the single-test alpha
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
            case "PointShape"
                PointShape = Args{JJ,2};
            case "Xlabels"
                Xlabels = Args{JJ,2};
            case "Signif"
                Signif = Args{JJ,2};
            case "SignifAlph"
                SignifAlph = Args{JJ,2};
            otherwise
                warning('Unknown option: %s',Args{JJ,1})
        end
    end
end

%% Loop to plot box charts and scatter
for JJ=1:length(InMat)
    % Populate secondary output struct with relevant descriptive statistics
    Output(JJ).Median = median(InMat{JJ});
    Output(JJ).Quartile = [prctile(InMat{JJ},25), prctile(InMat{JJ},25)];
    Output(JJ).IsOutlier = isoutlier(InMat{JJ},'quartiles');
    Output(JJ).Whisker = [min(InMat{JJ}(~Output(JJ).IsOutlier)), max(InMat{JJ}(~Output(JJ).IsOutlier))];

    if PlotOutliers
        bc(JJ) = boxchart(JJ*ones(1,length(InMat{JJ})),InMat{JJ},'BoxFaceColor',Colors(JJ,:),'MarkerColor',Colors(JJ,:),'BoxWidth',Width);
    else
        bc(JJ) = boxchart(JJ*ones(1,length(InMat{JJ})),InMat{JJ},'BoxFaceColor',Colors(JJ,:),'BoxFaceColor',Colors(JJ,:),'BoxWidth',Width,'MarkerStyle','none');
    end
    hold on

    if PointSize>0
        rng(abs(floor(sum(InMat{JJ},'omitnan')))); % Enable rng seed for reproducible randomization

        Jitter{JJ} = rand([1,length(InMat{JJ})]).*Width - Width/2 + JJ-Offset;

        scatter(Jitter{JJ}, InMat{JJ},'MarkerEdgeColor',Colors(JJ,:),...
                                      'MarkerFaceColor',Colors(JJ,:),...
                                      'MarkerEdgeAlpha',PointAlpha,...
                                      'MarkerFaceAlpha',PointAlpha,...
                                      'Marker',PointShape{JJ},...
                                      'SizeData',PointSize);
    end
end
Ax = gca;
Ax.XAxis.Visible = 'off'; % remove x-axis


%% Add optional xlabels

if ~isempty(Xlabels)
    for JJ=1:length(InMat)
        text(JJ,0,[Xlabels{JJ},'  '],'rotation',65,'horizontalalignment','right','fontsize',12,'color',Colors(JJ,:));
    end
end

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

%% Add significance annotations

if ~isempty(Signif)
    DynRange = max([Output.Whisker]) - min([Output.Whisker]);

    SLocs = Signif(:,1:2);
    Pval = Signif(:,3);
    
    if any(Pval>1) || any(Pval<0)
        error('Invalid p-value!')
    end

    for JJ=1:length(Pval)
        NStar = find(Pval(JJ)<SignifAlph,1,'last');
        Lab='';
        for KK=1:NStar
            Lab = [Lab,'*'];
        end
        
        if ~isempty(Lab)
            Yloc = max([Output(SLocs(JJ,1):SLocs(JJ,2)).Whisker]) + DynRange/100;
            Distance = abs(SLocs(JJ,1)-SLocs(JJ,2));
            if Distance>1
                Yloc = Yloc+Distance*DynRange/20;
            end

            plot([SLocs(JJ,1),SLocs(JJ,2)], [Yloc, Yloc],'k-');
            plot([SLocs(JJ,1),SLocs(JJ,1)], [Yloc-DynRange/100, Yloc+DynRange/100],'k-');
            plot([SLocs(JJ,2),SLocs(JJ,2)], [Yloc-DynRange/100, Yloc+DynRange/100],'k-');
            text(mean(SLocs(JJ,:)),Yloc,Lab,'FontSize',20,'HorizontalAlignment','center','VerticalAlignment','bottom'); 
        end
    end
end


%% Return figure handle only if outputs are requested
if nargout > 0
    BC = bc;
end

end