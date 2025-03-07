function[FormattedString] = FormatAuthorList(String)
%% function[FormattedString] = FormatAuthorList(String)
%
% Description: Reformat a string containing a list of full author names
% into a list that abbreviates first and middle names without periods
%
% Input:     String = Raw string
% Output:    FormattedString = String with formatting applied
%
% Example usage: FormatAuthorList('Christopher. W. Davies-Jenkins, A.N. Other')
%    Output:     'Davies-Jenkins CW, Other AN'
%
% C.W. Davies-Jenkins, Johns Hopkins University 2025
arguments
% Arg (size) {logical check} = Default 
% Arg (1,1) double {mustBeNumericOrLogical} = true;
String = []
end

SpltString = strsplit(String,',')';
FormattedString = '';

for JJ = 1:length(SpltString)
    AuthorSplit = strsplit(SpltString{JJ},{'.',' '});
    FormattedString = [FormattedString,AuthorSplit{end},' '];
    for KK=1:length(AuthorSplit)-1
        if ~isempty(AuthorSplit{KK})
            FormattedString = [FormattedString,strrep(AuthorSplit{KK}(1),'.','')]; 
        end
    end
    FormattedString = [FormattedString,', '];
end
FormattedString = FormattedString(1:end-2);

end
