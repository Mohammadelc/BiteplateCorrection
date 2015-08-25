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
%  Version: 2.0 2015-08-09
%  Author: Andrew Kolb and Michael T. Johnson
%  Reference: Quaternion Toolbox for MATLAB 
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qflip = [sqrt(2)/2 sqrt(2)/2 0 0];
bpcQuat = qmult(rotation,qmult(qflip,inQuat));

end