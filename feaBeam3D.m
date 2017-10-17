function feaBeam3D(filename,varargin)
% feaBeam3D.m
% This is the main file that implement a 3D linear beam elements
%
% Author: Dr. Mario J. Juha
% Date: 22/06/2017
% Mechanical Engineering
% Universidad de La Sabana
% Chia -  Colombia
%
global ID elements nn nel coordinates LM u forces neq
global irow icol nzmax


% Specify file name
%filename = '\Users\marioju\Documents\Work\VM12\examplePipe.inp';
%filename = '\\Client\C$\Users\marioju\Documents\Work\VM12\examplePipe.inp';

% check if user have specified rregression tests
if nargin > 1
    % extract the regression values
    normDisp = varargin{1};
    normRot = varargin{2};
    regressionTol = varargin{3};
end

% read data
outfile = readData(filename);
%
printInfo(filename)
%
% write original mesh
WriteVTKFile(outfile,0)

% ===========================
% assembling stiffness matrix
% ===========================
K = zeros(1,nzmax);
F = zeros(neq,1);
% set counter to zero
count = 0;
for i=1:nel
    xe = coordinates(elements(i,3:4),:);
    de = u(:,elements(i,3:4));
    matNum = elements(i,1);
    dirNum = elements(i,2);
    [fe,ke] = weakform(i,matNum,dirNum,xe,de);
    for k=1:12
        i_index = LM(k,i);
        if (i_index > 0)
            F(i_index) = F(i_index) + fe(k);
            for m=1:12
                j_index = LM(m,i);
                if (j_index > 0)
                    count = count + 1;
                    K(count) = ke(k,m);
                end
            end
        end
    end
end
% assign point loads
for i=1:size(forces,1)
    dof = forces(i,2);
    dir = forces(i,3);
    if dof == 1 % displacement
        i_index = ID(dir,forces(i,1));
    else % rotation
        i_index = ID(3+dir,forces(i,1));
    end
    F(i_index) = F(i_index) + forces(i,4);
end
M = sparse(irow,icol,K,neq,neq);
F = M\F;
% assign solution
for r=1:nn
    for s=1:6
        i_index = ID(s,r);
        if (i_index > 0)
            u(s,r) = F(i_index);
        end
    end
end

%
computeStressStrain
%
% % write solution
WriteVTKFile(outfile,1)

% do regression test
if nargin > 1
    regressionTests(normDisp,normRot,regressionTol)
end

end
