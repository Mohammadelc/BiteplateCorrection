function [bpcQuat] = correctQuat(inQuat, rotation)
% FUNCTION_NAME correctQuat FUNCTION DESCRIPTION Apply biteplate correction
% to the quaternion data, making the subject's right side the baseline
% orientation.
%  
%  correctQuat(inQuat, rotation)
%  
%  Inputs:
%           inQuat: Quaternion or quaternion matrix with each row being a
%           quaternion value.
%           
%           rotation: The rotation amount calculated by the BPRotation
%           Function, as applied to the biteplate data.
%           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Requirements: Quaternion Toolbox for MATLAB
%  Version: 2.0 2014-5-22 
%  Author: Andrew Kolb
%  Reference: Quaternion Toolbox for MATLAB 
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Baseline is negative z because quaternions were with respect to positive
    % z-axis in the head-corrected space.  We negated the z values when
    % switching the x and y axes in BPRotation.
    baseline = [0 0 -1];

    %Calculate the original vector normal to the plane of the sensor
    origNorm = qvqc(inQuat,baseline);
    oldZ = [0 0 1];

    %Rotate the z-axis to represent the new-z axis
    newZ = qcvq(rotation, oldZ);
    newZ = repmat(newZ,size(inQuat,1),1);

    %Calculate the quaternion between the new baseline and the original norm
    %vector.
    bpcQuat = getQuat(newZ,origNorm);

end

