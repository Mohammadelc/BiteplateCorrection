% FUNCTION_NAME CheckSensors FUNCTION DESCRIPTION Determine whether or not the sensors were connected to the subject in the proper (expected) manner.
% 
%  CheckSensors(tsvFile, offset)
%  
%  Inputs:
%           tsvFile:         File name needs to be processed
%           offset:          origin offset in biteplate coordinate
%           
%   Compares average value of sensor positions, which assumes that sensors configuration consistant with the following rules:
%   1.  For bite plate record, OS position is around offset; MS has negative x-position, y and z position is around offset
%   2.  Dorsal tongue sensor (TD) has the lowest x-position value, followed by the TL sensor, and finally TB. 
%   3.  TL sensor has positive z-position value
%   4.  Lateral lip sensor has most negative z-position value.  (THIS SHOULD
%   BECOME MOST NEGATIVE if the coordinates get switched)
%   5.  Upper lip is above lower lip and inscisor (greater in y), and both of these sensors have positive x-position values 
%  
%   This test should be used only for general screening purposes, and all noted deviations should be assessed on a subject-by-subject basis.
%                    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Version: 2.0 2014-5-22 
%  Author: Andrew Kolb and An Ji
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function CheckSensors(tsvFile, offset)
    %Load the tsv
    [data, header] = loadtsv(tsvFile);
    %Each sensor will be a row vector with 3 cols (X, Y, Z)
    %These are the expected columns for a given sensor.
    % check OS and MS :
    OS=nanmean(data(:,87:89));
    MS=nanmean(data(:,96:98));
    varOS=nanvar(data(:,87:89));
    varMS=nanvar(data(:,96:98));
    if ((OS(1)+offset(1)) > 0.0001) || ((OS(2)+offset(2)) > 0.0001) || ((OS(1)+offset(1)) > 0.0001)
        error('The coordinates of original (OS) is not correct, please check the BitePlate correction!');
    end
    if (MS(1) > -15) || ((MS(2)+offset(2)) > 0.0001) || (MS(3) > 0.0001)
         error('The coordinates of MS is not correct, please check the BitePlate correction!');
    end
    
    if varOS(1) > 0.05 || varOS(2) > 0.05 || varOS(3) > 0.05 || varMS(1) > 0.05 || varMS(2) > 0.05 || varMS(3) > 0.05
        warning('The variance of OS or MS is high!!  This suggests the head correction of raw data was not accurate.')
    end
        
    % check sensor location   
    TD_x=nanmean(data(:,15)); TD_y=nanmean(data(:,16));TD_z=nanmean(data(:,17));
    TL_x=nanmean(data(:,24)); TL_y=nanmean(data(:,25));TL_z=nanmean(data(:,26));
    TB_x=nanmean(data(:,33)); TB_y=nanmean(data(:,34));TB_z=nanmean(data(:,35));
    UL_x=nanmean(data(:,42)); UL_y=nanmean(data(:,43));UL_z=nanmean(data(:,44));
    LL_x=nanmean(data(:,51)); LL_y=nanmean(data(:,52));LL_z=nanmean(data(:,53));
    LC_x=nanmean(data(:,60)); LC_y=nanmean(data(:,61));LC_z=nanmean(data(:,62));
    MI_x=nanmean(data(:,69)); MI_y=nanmean(data(:,70));MI_z=nanmean(data(:,71));
   
    
    % Check tongue sensors
    if (TD_x < 0) && (TL_x <0) && (TB_x < 0)
        if (TD_x < TL_x) && (TL_x< TB_x)
            if TL_z > 0
               CheckTongue='correct';
            else
                error('Lateral tongue sensor has negative z value, check!!');
            end
        else
            error('The order of tongue sensors is incorrect! Check the position!!');
        end
    else
            error('Tongue sensor has positive x value, please check!!');
    end
        
    % Check lip sensors
     if (UL_x > 0) && (LL_x > 0)
        if (UL_y > 0) && (LL_y < 0)
            if LC_z < 0
               CheckLip='correct';
            else
                error('Lip corner sensor has positive z value, check!!');
            end
        else
            error('Upper lip and lower lip sensors are incorrect in y value! Check the position!!');
        end
    else
            error('Check lip sensors for x value');
     end
    
    % Check MI sensor
    if (MI_y) < 0
        if abs(MI_z) < 10
            CheckMI='correct';
        else
            error('Jaw sensor has large z value, check!!')
        end
    else
        error('Jaw sensor has position y value, check!!')
    end
  
if strcmp(CheckTongue,'correct') && strcmp(CheckLip,'correct') && strcmp(CheckMI,'correct')
    disp('Pass: all sensors positions are in the correct configuation');
end
end

