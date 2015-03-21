% FUNCTION_NAME BPRotation FUNCTION DESCRIPTION Calculate translation value and rotation vector from the raw bite-plate record
%  
%  BPRotation(BPfile, velThreshold)
%  
%  Input:
%         BPfile: Bite plate record filename
%         velThreshold: Velocity threshold which will be used to discard
%         points with only pairs of points with velocities less than this
%         value included in the head-correction calculation
% 
% Save translation and rotation infomation into mat file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Requirements: Quaternion Toolbox for MATLAB
%  Version: 2.0 2014-5-22 
%  Author: An Ji and Andrew Kolb
%  Reference: Quaternion Toolbox for MATLAB 
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BPRotation(BPfile,velThreshold)

if(nargin<2)
    velThreshold = 25;
end
% load bite-plate record
[rawdat,header]=loadtsv(BPfile); 

% check the number of sensors
Ncolumn =length(header);
Nsensors =(Ncolumn-3)/9;
if rem(Nsensors,1) ~= 0
    error('The number of sensors is not a integer!')
end

% swap x and y axis, negate z except for sensor 1
Swapdat=rawdat;
for j=1:Nsensors-1
    %Position values
    Swapdat(:,6+9*j)=rawdat(:,7+9*j);
    Swapdat(:,7+9*j)=rawdat(:,6+9*j);
    Swapdat(:,8+9*j)=-rawdat(:,8+9*j);
     
   %Quaternion Values-- leave Qo alone
   Swapdat(:,10+9*j)=rawdat(:,11+9*j);
   Swapdat(:,11+9*j)=rawdat(:,10+9*j);
   Swapdat(:,12+9*j)=-rawdat(:,12+9*j);
end

if(velThreshold)
    %Calculate head velocity using the reference sensor position values
    timestep = median(diff(rawdat(:,1)));
    refdat = Swapdat(:,6:8);
    velocity = smooth(sqrt(sum((diff(refdat)/timestep).^2,2)));
    inds = find(velocity<25);
    inds = inds+1;
    OS_raw = Swapdat(inds,87:89);
    MS_raw = Swapdat(inds,96:98);
else
    OS_raw=Swapdat(:,87:89);
    MS_raw=Swapdat(:,96:98);
end

% calculate the translation value and rotation vetor

MS=nanmean(MS_raw);
OS=nanmean(OS_raw);   % translation value
REF=[0 0 0];
Ref_t=REF-OS;
MS_t=MS-OS;
z=cross(MS_t,Ref_t);
z=z/norm(z);
y=cross(z,MS_t);
y=y/norm(y);
l1=dot(y,Ref_t)/norm(y);l2=norm(MS_t);
Ref_tnew=[0 abs(l1) 0];
MS_tnew=[-1*abs(l2) 0 0];
Ref_ty=y*abs(l1)/norm(y);

x1=MS_t; x2=MS_tnew; y1=Ref_ty; y2=Ref_tnew;

norm1=cross(x1,x2); norm1=norm1/norm(norm1); norm2=cross(y1,y2); norm2=norm2/norm(norm2);
f1=cross(norm1,(x1+x2)/2);  f1=f1/norm(f1); f2=cross(norm2,(y1+y2)/2); f2=f2/norm(f2);
axis=cross(f1,f2);
axis=axis/norm(axis);

r=norm(x1)*sin(acos((dot(x1,axis))/(norm(x1)*norm(axis))));
theta=asin((sqrt((x1(1)-x2(1))^2+(x1(2)-x2(2))^2+(x1(3)-x2(3))^2)/(2*r)));
%AJK FIX
if(theta>(pi/2))
    theta = pi - theta;
end

q0=cos(theta);
qx=sin(theta)*axis(1);
qy=sin(theta)*axis(2);
qz=sin(theta)*axis(3);

q=[qx qy qz q0]; 

% Sanity checking
MS_new1=qvrot(q,MS-OS);
MS_new2=qvrot(qconj(q),MS-OS);
if (MS_new1(2)<0.000001 && MS_new1(3)<0.000001)
   rotation=q;
else if (MS_new2(2)<0.000001 && MS_new2(3)<0.000001)
   rotation=qconj(q);
    end
end

%Save it in the current Matlab working directory
[pathstr, name, ext] = fileparts(BPfile);
% save translation value and rotation vector
save([name '_BPInfo.mat'], 'OS', 'rotation');

end
