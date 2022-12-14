function [Tabular] = cell2latex( InputCell )
%% function [Tabular] = cell2latex( InputCell )
%
% Function for generating LaTeX table strings from a cell array.
%
% Input:   InputCell = Any cell array
% Output:  Tabular   = Latex table string
%
% C.W.Davies-Jenkins, Johns Hopkins University 2022


S=size(InputCell);
%S(1)=rows -- K
%S(2)=cols -- J

for K=1:S(1)
    for J=1:S(2)        
        if isnan(InputCell{K,J})
            InputCell{K,J} = '';
        elseif isnumeric(InputCell{K,J})
            InputCell{K,J} = num2str(InputCell{K,J});
        end
        Temp=char(InputCell{K,J});
        
        if J==1             %1st row
            Row = Temp;
            Header = '\begin{tabular}{|c|';
        elseif J==S(2)       %Last row
            Row = sprintf('%s & %s \\\\',Row,Temp);
            Header = sprintf('%sc|}\n\\hline',Header);
        else                  %Any other row
            Row = sprintf('%s & %s',Row,Temp);
            Header=sprintf('%sc|',Header);
        end
    end  
    if K==1
        Table = Row;
        if K==S(1)
            Table = sprintf('%s\n\\hline\n\\end{tabular}',Table);
        end
    elseif K==S(1)
        Table = sprintf('%s\n%s\n\\hline\n\\end{tabular}',Table,Row);
    else       
        Table = sprintf('%s\n%s',Table,Row);
    end
end

Tabular = sprintf('%s\n%s',Header,Table);

end