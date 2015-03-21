% FUNCTION_NAME BiteplateCorrect FUNCTION DESCRIPTION Apply biteplate correction for the tsv file
%  
%  BiteplateCorrect(ProcessFileName, BPInfo, flag, offset)
%  
%  Inputs:
%           ProcessFileName: File name needs to be processed
%           BPInfo:          Translation and Rotation information file
%           offset:          origin offset in biteplate coordinate
%           flag:            1: Check sensors' coordinates after biteplate correction 
%                            0: Don't check sensors' coordinates
%           
%                    
%  Notice: The first sensor is a 6 DOF reference sensor which uses 2 channels and it is in the global coordinate space.
%          All others are 5 DOF use 1 channel
%          The bite-plate correction applied to all sensors expect the first reference sensor
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Requirements: Quaternion Toolbox for MATLAB
%  Version: 2.0 2014-5-22 
%  Author: An Ji and Andrew Kolb
%  Reference: Quaternion Toolbox for MATLAB 
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function BiteplateCorrect(ProcessFileName, BPInfo, flag, offset)

if (nargin<4)
    offset=[-4,-1,0]; % default value for the offset
end

% load BPInfo
load(BPInfo);

% load tsv file which needs to be processed
[raw,header]=loadtsv(ProcessFileName);   

% check for number os columns
Ncolumn =length(header);
Nsensors =(Ncolumn-3)/9;
Nrow = length(raw(:,1));
OSvec = repmat(OS,Nrow,1);
offsetvec = repmat(offset,Nrow,1);
if rem(Nsensors,1) ~= 0
    error('The number of sensors is not a integer!')
end

% swap x and y axis except for sensor 1
% Swap Qx and Qy as well, making Qz negative
%         to reflect change in axes
Swapdat_file=raw;
for j=1:Nsensors-1
   %Position Values
   Swapdat_file(:,6+9*j)=raw(:,7+9*j);
   Swapdat_file(:,7+9*j)=raw(:,6+9*j);
   Swapdat_file(:,8+9*j)=-raw(:,8+9*j);
   
   %Quaternion Values-- leave Qo alone
   Swapdat_file(:,10+9*j)=raw(:,11+9*j);
   Swapdat_file(:,11+9*j)=raw(:,10+9*j);
   Swapdat_file(:,12+9*j)=-raw(:,12+9*j);
   
end
   BPCorrect=Swapdat_file;
tic
% Bite plate correction
for j=1:Nsensors-1
   % Applying translation by subtraction 'OS' value and rotation by 'qvrot' function
   BPCorrect(:,6+9*j:8+9*j)=qvrot(rotation,Swapdat_file(:,6+9*j:8+9*j)-OSvec)-offsetvec; 
   % The quaternion rotation places the baseline orientation vector on the
   % positive z-axis (subject's right).
   q_out=correctQuat([Swapdat_file(:,(10+9*j)) Swapdat_file(:,(11+9*j)),Swapdat_file(:,(12+9*j)), Swapdat_file(:,(9+9*j))], rotation); 
   BPCorrect(:,9+9*j:12+9*j)=[q_out(:,4) q_out(:,1) q_out(:,2) q_out(:,3)];
end
toc
%Save it in the "Corrected" folder in the database
[path name ext] = fileparts(ProcessFileName);
newPath = regexprep(path,'Raw','Corrected');
outputFile = strcat(newPath,'\',name,'_BPC',ext);
writetsv(outputFile,BPCorrect,header, 3);

% If flag=1 check sensors' coordinates after bite plate correction (check bite plate record after correction for each subject)
if flag
   CheckSensors([ProcessFileName(1:end-4) '_BPC.tsv'], offset)
end
      
end
