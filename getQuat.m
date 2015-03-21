function [quat] = getQuat(initial, final)
% FUNCTION_NAME getQuat FUNCTION DESCRIPTION Returns the quaternion
% representing the change in orientation between two vectors
%  
%  getQuat(initial,final)
%  
%  Inputs:
%          initial:  quaternion or matrix of quaternions, where each
%          quaternion is stored in a row of the matrix.  Represents the
%          initial orientation of the vector.
%           
%          final:  quaternion or matrix of quaternions, where each
%          quaternion is stored in a row of the matrix.  Represents the
%          final desired orientation of the vector.
%                    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Requirements: None
%  Author: Andrew Kolb
%  The toolbox for Marquette EMA-MAE database is distributed under the terms of the GNU General Public License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Error Checking
    initNorms = arrayfun(@(idx) norm(initial(idx,:)), 1:size(initial,1));
    finalNorms = arrayfun(@(idx) norm(final(idx,:)), 1:size(final,1));
    
    if(ismember(0,initNorms) || ismember(0,finalNorms))
        error('Input vectors must all have non-zero length.');
    elseif(size(initial) ~= size(final))
        error('Input vector sizes must match!');
    end
    
    %Normalize the quaternion input matrices
    normInitial = arrayfun(@(idx) initial(idx,:)./initNorms(idx), 1:length(initNorms), 'UniformOutput',0);    
    normFinal = arrayfun(@(idx) final(idx,:)./finalNorms(idx), 1:length(finalNorms), 'UniformOutput',0);
    
    %Make them matrices again instead of cells
    normInitial = reshape(cell2mat(normInitial)',size(initial,2),size(initial,1))';
    normFinal = reshape(cell2mat(normFinal), size(final,2),size(final,1))';
    
    %This is where the magic happens.  The following formula is used:
    %   a = initial vector
    %   b = final vector
    %
    %   q.xyz = cross(a,b)
    %   q.w   = sqrt(norm(a).^2*(norm(b).^2)) + dotproduct(a,b)
    %
    %   We can make the sqrt part 1.0, as the vectors are all unit vectors.
    %   NOTE: The rotation between two vectors is not unique, so the
    %   quaternion corresponding to the shortest arc has been used.
    
    dotProducts = arrayfun(@(idx) dot(normInitial(idx,:),normFinal(idx,:)), 1:size(initial,1));
    q0 = (ones(1,size(normInitial,1)) + dotProducts)';
    axis = arrayfun(@(idx) cross(normInitial(idx,:),normFinal(idx,:)), 1:size(normInitial,1),'UniformOutput',0);
    axisMat = reshape(cell2mat(axis)', size(initial,2),size(initial,1))';
    quat = [axisMat, q0];
    
    %Here we need to handle the exception for 180 degree rotation
    %where crossproduct = [0 0 0] and the dot product is negative.
    for i=1:size(quat,1)
        if((norm(quat(i,1:3)) < 1.6e-12)  && (quat(i,4) <0))
            quat(i,4) = 0;
            if(normInitial(i,1) > normInitial(i,3))
                quat(i,1:3) = [-normInitial(i,2) normInitial(i,1) 0];
            else
                quat(i,1:3) = [0 -normInitial(i,3) normInitial(i,2)];
            end
        end
    end
    
    %Normalize the final output quaternion and return in a nice matrix
    quatNorms = arrayfun(@(idx) norm(quat(idx,:)), 1:size(quat,1));
    normQuat= arrayfun(@(idx) quat(idx,:)./quatNorms(idx), 1:length(quatNorms), 'UniformOutput',0);
    quat = reshape(cell2mat(normQuat)', size(quat,2),size(quat,1))';
end