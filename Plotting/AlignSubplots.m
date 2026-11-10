function[] = AlignSubplots(FigHandles, Ax, AlignAcrossFig, BuffFact)
%% function[] = AlignSubplots(FigHandles, Ax, BuffFact)
%
% Description: Aligns the x and/or y axis limits for different subplots
% across several figures
%
% Input:     FigHandles = Vector of figure handles
% Optional:  Ax = String of the axes to adjust: 'x', 'y', or 'xy' for both
%            BuffFact = Scale factor for buffer around the points, i.e.,
%                    Xlim = [Xlower-BuffFact*(Xupper-Xlower), Xupper+BuffFact*(Xupper-Xlower)
%
% C.W. Davies-Jenkins, Johns Hopkins University 2026

if ~all(isgraphics(FigHandles))
    error('One or more invalid figure handles!')
end
if ~exist("Ax","var")
    Ax = 'xy';
end
if ~exist("AlignAcrossFig","var")
    AlignAcrossFig = 0;
end
if ~exist("BuffFact","var")
    BuffFact = 0;
end

%% Find how many subplots we expect, using the first as an example

axHandles = findobj(figure(FigHandles(1)), 'Type', 'axes');
NChild = length(axHandles);

%% Extract the upper and lower x and y limits across all subplots
for JJ_Child = 1:NChild
    Xu = [];
    Xl = [];
    Yu = [];
    Yl = [];
    for JJ_Fig=1:length(FigHandles)
        axHandles = findobj(figure(FigHandles(JJ_Fig)), 'Type', 'axes');
        targetSubplot = axHandles(JJ_Child);
        allLines = findobj(targetSubplot, 'Type', 'line');
        for JJ_Line = 1:length(allLines)


            Xl = min([Xl, allLines(JJ_Line).XData]);
            Xu = max([Xu, allLines(JJ_Line).XData]);
            Yl = min([Yl, allLines(JJ_Line).YData]);
            Yu = max([Yu, allLines(JJ_Line).YData]);
        end
    end
    Xlo(JJ_Child) = Xl;
    Xuo(JJ_Child) = Xu;
    Ylo(JJ_Child) = Yl;
    Yuo(JJ_Child) = Yu;
end

%% If enabled, align the axes limits within each figure too!
if AlignAcrossFig
        % Grab axis positions for all subplots
        Locs = reshape([axHandles(:).Position],4,[])';Locs = Locs(:,1:2);

        switch Ax
            case 'x' % x-aligned sub-plots share x axes 
                xLocs = unique(Locs(:,1));
                for JJ=1:length(xLocs)
                    Bool = xLocs(JJ)==Locs(:,1);
                    Xlo(Bool) = min(Xlo(Bool));
                    Xuo(Bool) = min(Xuo(Bool));
                end
            case 'y' % y-aligned sub-plots share y axes
                yLocs = unique(Locs(:,2));
                for JJ=1:length(yLocs)
                    Bool = yLocs(JJ)==Locs(:,2);
                    Ylo(Bool) = min(Ylo(Bool));
                    Yuo(Bool) = min(Yuo(Bool));
                end
            case 'xy'
                keyboard
        end
end       

%% Apply them to corresponding subfigures
for JJ_Child = 1:NChild
    for JJ_Fig=1:length(FigHandles)
        axHandles = findobj(figure(FigHandles(JJ_Fig)), 'Type', 'axes');
        targetSubplot = axHandles(JJ_Child);
        if contains(Ax,'x')
            RangeBuff = BuffFact*(Xuo(JJ_Child)- Xlo(JJ_Child));
            targetSubplot.XLim = [Xlo(JJ_Child)-RangeBuff, Xuo(JJ_Child)+RangeBuff];
        end
        if contains(Ax,'y')
            RangeBuff = BuffFact*(Yuo(JJ_Child)- Ylo(JJ_Child));
            targetSubplot.YLim = [Ylo(JJ_Child)-RangeBuff, Yuo(JJ_Child)+RangeBuff];
        end
    end
end

end