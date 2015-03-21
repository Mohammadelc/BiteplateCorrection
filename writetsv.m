function writetsv(filename, m, headers,decPlaces)
%function writetsv(filename, m, headers)
%
% Writes NI Wave TSV files
%
% Inputs:
%         filename: filename
%                m: data matrix formatted same as loadtsv output
%          headers: headers cell array from loadtsv
%          decPlaces: how many decimal places to write out to
%
%-------------------------------------------------------------------------------
if(nargin<4)
    decPlaces = 12;
end
fid = fopen(filename ,'Wb');
if fid == (-1)
    error(message('Writetsv: FileOpenFailure', filename));
end

% Write header row
%newline = sprintf('\n');
numheaders=length(headers); s=[];
for ii=1:numheaders
    s=[s sprintf('%s\t',headers{ii})];
end
s=s(1:(end-1));  % delete last tab
fwrite(fid, s, 'uchar');
fprintf(fid, '\r\n','char'); % terminate this line

format = sprintf('%%.%dg%s',10,'\t');
[br,bc] = size(m);

% for tsv files, should be 3 leading columns, then 9 cols for each sensor
ns=floor(bc/9);  % number of sensors
if (bc~=(3+9*ns))
    error('Number of columns not equal to 3 plus 9 * (number of sensors)');
end

% Don't know why first sensor has different precision, but in ND tsv files it does
finit='%.4f\t%d\t%d\t';   % first 3 columns format string
ffirst='%d\t%d\t%6.f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t'; % first sensor
frep='%d\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t';   % each sensor
flast='%d\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f';    % last sensor
if(decPlaces~=12)
    ffirst = regexprep(ffirst,'\.6',strcat('\.',num2str(decPlaces)));
    frep = regexprep(frep,'\.12',strcat('\.',num2str(decPlaces)));
    flast = regexprep(flast,'\.12',strcat('\.',num2str(decPlaces)));
end
format=[finit ffirst];
for i=2:(ns-1)
    format=[format frep];
end
format=[format flast];

for i = 1:br
        str = sprintf(format,m(i,:));
        str=strrep(str,'NaN','');        %MTJ Remove ALL NaN prints, leave delimiters
        fwrite(fid, str, 'uchar');
        fprintf(fid,'\r\n'); % terminate this line
end

% close file
fclose(fid);