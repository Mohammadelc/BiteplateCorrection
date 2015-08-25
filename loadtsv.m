function [rawdat,header]=loadtsv(fname)
% function [rawdat,header]=loadtsv(fname)
%
% function to read in a tsv file
%
% reference: columns in resulting data:
% Cols 1,2,3 : Audio time| Measurement Index | Audio Index
% Then 9 cols/sensor: Cols (4+9*n) to (12+9*n)) : Sensor number n, n=0..N-1
% 1st two    = (4+9*n) to (5+9*n)  : Sensor ID | Sensor Status
% Next three = (6+9*n) to (8+9*n)  : position x | y | z
% Next four  = (9+9*n) to (12+9*n) : orientation quaternion q0 | qx | qy | qz
x=importdata(fname,'\t');

rawdat=x.data;

header = x.textdata;
% if last sensor has no data, just delimiters, importdata doesn't read those columns
% need to fill it in so it will get written back out correctly 
[nrows,ncols]=size(rawdat);
lenheader=length(header);
if (ncols~=lenheader)  
    rawdat(:,(ncols+1):(lenheader))=NaN;
end
