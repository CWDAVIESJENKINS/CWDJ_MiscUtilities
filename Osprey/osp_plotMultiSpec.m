function[] = osp_plotMultiSpec(InputCell,Group,Size,AddLegend,Lims)
%% function[] = osp_cwdj_plotMultiSpec2(InputCell,Group,Size,OutName,Leg,Lims)
%
% Input:        InputCell=Cell array of MRSConts run up to OspreyOverview
% Optional:     Group=Cell array of group labels (Single group by default)
%               Size=size of facet (square grid by default)
%               AddLegend=Binary for legend inclsion. (Off by default)
%               Lims=Ylims of plot. ('auto' by default)
%
% C.W.Davies-Jenkins Johns Hopkins Medicine, 2022

% If no limits supplied, auto scale
if ~exist('Lims','var')
    Lims = 'auto';
end
if ~exist('AddLegend','var')
    AddLegend = true;
end

%% Extract specs from MRSConts
Specs = [];
for JJ = 1:length(InputCell)%Loop over cells
    MRSCont = InputCell{JJ};
    for KK=1:length(MRSCont.fit.results.metab.fitParams)%Loop over model calls within cells
        Ref_Ind = MRSCont.fit.results.metab.fitParams{KK}.ppm>2.9 & MRSCont.fit.results.metab.fitParams{KK}.ppm<3.15;
        Specs = [Specs,MRSCont.fit.results.metab.fitParams{KK}.data ./ max(MRSCont.fit.results.metab.fitParams{KK}.data(Ref_Ind))];
    end
end

%% 
PPM = MRSCont.fit.results.metab.fitParams{1}.ppm;
if ~exist('Group','var')
    PlotAllSpec(PPM, Specs, MRSCont.colormap,Lims);
else
    UG = unique(Group);
    L = length(UG);
    if ~exist("Size", 'var') || Size==0
        % If no size explicitly stated, assume square layout
        Size = [ceil(sqrt(L)),ceil(sqrt(L))];
    end
    tiledlayout(Size(1),Size(2),'TileSpacing','none','Padding','Compact')
    for JJ = 1:L %Loop over unique groups
        nexttile;
        
        Ind = contains(Group,UG{JJ});
        PlotAllSpec(PPM, Specs(:,Ind), MRSCont.colormap,Lims);% Plotting!
        title(UG{JJ})
        if AddLegend
            title(UG{JJ})
        end
        if ceil(JJ/Size(2))< Size(1)
            ax1 = gca;
            ax1.XAxis.Visible = 'off';   % remove x-axis for plots outside of bottom row
        end
    end    
end

if AddLegend
    legend([All(1),Mean,Fill], {'Individual spectra','Mean','STD'})
end

end


%% Internal functions
function[] = PlotAllSpec(PPM, Specs, CM, Lims)

Mean = mean(Specs,2);
Std = std(Specs,1,2);

Y1 = Mean+Std;
Y2 = Mean-Std;

x2 = [PPM', fliplr(PPM')];
%x2 = [PPM, fliplr(PPM)];
inBetween = [Y1', fliplr(Y2')];

Fill = fill(x2, inBetween,[0.0,0.75,1.0]);
hold on
All = plot(PPM, Specs,'color',[0.15,0.15,0.15,0.15],'LineWidth',0.3);
Mean = plot(PPM, mean(Specs,2),'y','LineWidth',1.2);


% Adapt common style for all axes
set(gca, 'XDir', 'reverse', 'XLim', [0.3, 4.3], 'XMinorTick', 'On');
set(gca, 'LineWidth', 1, 'TickDir', 'out');
set(gca, 'FontSize', 16);
box off;

% REmove Yaxis and scale
ax1 = gca;                   % gca = get current axis
ax1.YAxis.Visible = 'off';   % remove y-axis
ylim(Lims);

% Dirtywhite axes, light gray background
set(gca, 'XColor', CM.Foreground);
set(gca, 'Color', CM.Background);
set(gcf, 'Color', CM.Background);

xlabel('PPM', 'FontSize', 16);
end