function[] = NewFile()
%% function[] = NewFile()
%
% Description: Function for templating the header of Matlab files
%
% Example usage:
%               NewFile
%
% C.W. Davies-Jenkins, Johns Hopkins University 2023


CellTemplate = {'function[] = FName()'...
            '%% function[] = FName()'...
            '%' ...
            '% Description: '...
            '%'...
            '% Input:     Arg1 = '...
            '% Output:    Arg1 = '...
            '% Optional:  Arg1 = '...
            '%'...
            '% Example usage:'...
            '%'...
            ['% C.W. Davies-Jenkins, Johns Hopkins University ', sprintf('%i',year(today))]...
            'arguments'...
            '% Arg (size) {logical check} = Default ' ...
            '% Arg (1,1) double {mustBeNumericOrLogical} = true;'...
            'end'...
            ''...
            ''...
            'end'
            };


edit;                                      %New file
hEditor = matlab.desktop.editor.getActive; %its handle
for JJ = 1:numel(CellTemplate)
    appendText(hEditor,sprintf('%s\n',CellTemplate{JJ}));
end

end