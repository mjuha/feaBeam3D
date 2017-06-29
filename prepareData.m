function prepareData
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global ID elements nn nel DBCSet PFCSet coordinates LM u forces neq
% global stress strain

% ====================
% assembling ID array
% ====================
ID = ones(6,nn);
[ndispl,~] = size(DBCSet);

% initialize solution vector
u = zeros(6,nn);

% prescribed displacements and rotations
for i=1:ndispl
    centinel = 0;
    vx = DBCSet(i,1:3);
    for j=1:nn
        if norm(coordinates(j,1:3)-vx) < 1.0e-12
            dof = DBCSet(i,4);
            dir = DBCSet(i,5);
            val = DBCSet(i,6);
            if dof == 1 % displacements
                ID(dir,j) = 0;
                % initialize solution vector
                u(dir,j) = val;
            else % rotations
                ID(3+dir,j) = 0;
                % initialize solution vector
                u(3+dir,j) = val;
            end
            centinel = 1;
            break
        end
    end
    if centinel == 0
        error('DBC not found, please check!')
    end
end
% Fill ID array
count = 0;
for j=1:nn
    for i=1:6
        if ( ID(i,j) ~= 0 )
            count = count + 1;
            ID(i,j) = count;
        end
    end
end

% number of equations
neq = max(max(ID));

% =================
% Generate LM array
% =================
LM = zeros(12,nel);
for k=1:nel
    for a=1:2
        for i=1:6
            p = 6*(a-1) + i;
            LM(p,k) = ID(i,elements(k,a+2));
        end
    end
end

% prescribed forces
[nforces,~] = size(PFCSet);
forces = zeros(nforces,4);
for i=1:nforces
    centinel = 0;
    vx = PFCSet(i,1:3);
    for j=1:nn
        if norm(coordinates(j,1:3)-vx) < 1.0e-12
            forces(i,1) = j;
            dof = PFCSet(i,4);
            dir = PFCSet(i,5);
            value = PFCSet(i,6);
            forces(i,2) = dof;
            forces(i,3) = dir;
            forces(i,4) = value;
            centinel = 1;
            break
        end
    end
    if centinel == 0
        error('PFC not found, please check!')
    end
end

% compute sparsity
ComputeSparsity

% stress = zeros(nel,1);
% strain = zeros(nel,1);

end

