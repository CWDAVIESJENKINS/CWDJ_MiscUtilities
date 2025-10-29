function[Fig] = figure2(Fig,AspectRatio,Width)
%% function[] = figure2(Fig,AspectRatio,Width)
%
% Description: Creates a figure panel with a fixed aspect
% ratio, and width according to MRM figure guidelines:
% https://onlinelibrary.wiley.com/pb-assets/assets/15222594/nav/MRM_Style_Guide_Nov-2022-1669644630257.pdf?msockid=3c5d7e313a346b263a936d9d3b266ac8#page=10.62
% 
%   Type   | Width (inch) |  Description
% 'single' |     3.42     |  Single column
%  '1.5'   |     5.12     |  1.5 columns
% 'double' |     6.9      |  Double column
% 'depth'  |     9.5      |  Page depth
%
% It also sets the default font and font size
%
% Input:     Fig = Figure handle
%            AspectRatio = length as a factor of width (i.e. 1 for square)
% Optional:  Width = The figure panel width (either a string from the above
%                   table, or numeric value in inches). Default = 'double',
%                   i.e. double-column figure
%
% Example usage:
%
%   figure2(1,2)           % <- this creates a double-column figure 2x longer than tall
%   figure2(1,1,'single')  % <- this creates a single-column square figure
%
% C.W. Davies-Jenkins, Johns Hopkins University 2024
arguments
Fig (1,1) double {mustBeInteger} = gcf
AspectRatio (1,1) double = 1
Width = 'double'
end
%% Defaults
DefFont = 'Arial';
DefSize = 11;

%% Input handling
% Handle width input
if isnumeric(Width)
    WidthVal = Width;
else
    switch Width
        case 'single'
            WidthVal = 3.42;
        case '1.5'
            WidthVal = 5.12;
        case 'double'
            WidthVal = 6.9;
        case 'depth'
            WidthVal = 9.5;
    end
end

% Derive Height from aspect ratio
Height = AspectRatio * WidthVal;

%% Ammend the figure

FIG = figure(Fig);

set(FIG,'Units','Inches');      % Fix figure units to inches
pos = [0,0,WidthVal,Height]; % Ammend the height and width
set(FIG,'Position',pos);        %

% Set the default font and font size. 
% Note: this will be overwritten by existing fonts in the figure
set(FIG, 'DefaultAxesFontName', DefFont);
set(FIG, 'DefaultAxesFontSize', DefSize);
set(FIG, 'DefaultTextFontName', DefFont);
set(FIG, 'DefaultTextFontSize', DefSize);

end