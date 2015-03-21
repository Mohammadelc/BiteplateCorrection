function [qout] = qaxisrot(q1, q2)
% FUNCTION_NAME qaxisrot FUNCTION DESCRIPTION Rotates the quaternion axis
% while maintaining the angle of rotation about the axis.
%  
%  qaxisrot(q1, q2)
%  
%  Inputs:
%           q1 = quaternion whose axis will be rotated.
%           q2 = quaternion that represents the rotation applied to the
%           axis
%                    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Requirements: Quaternion Toolbox for MATLAB
%  Version: 2.0 2014-5-22 
%  Author: Andrew Kolb
%  Reference: Quaternion Toolbox for MATLAB 
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axis = (q1 - qconj(q1))./2;
axis = axis(1:3);
newAxis = qvqc(q2,axis);
qout = [newAxis q1(4)];

end

