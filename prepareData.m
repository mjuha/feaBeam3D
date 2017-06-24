function prepareData
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global ID elements nn nel DBCSet PFCSet coordinates LM u forces
global stress strain

% ====================
% assembling ID array
% ====================
ID = ones(2,nn);
[ndispl,~] = size(DBCSet);

% initialize solution vector
u = zeros(2,nn);

% prescribed displacements
for i=1:ndispl
    centinel = 0;
    vx = DBCSet(i,1:2);
    for j=1:nn
        if norm(coordinates(j,1:2)-vx) < 1.0e-12
            dof = DBCSet(i,3);
            ID(dof,j) = 0;
            centinel = 1;
            % initialize solution vector
            u(dof,j) = DBCSet(i,4);
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
    for i=1:2
        if ( ID(i,j) ~= 0 )
            count = count + 1;
            ID(i,j) = count;
        end
    end
end

% =================
% Generate LM array
% =================
LM = zeros(4,nel);
for k=1:nel
    for j=1:2
        for i =1:2
            p = 2*(j-1) + i;
            LM(p,k) = ID(i,elements(k,j+1));
        end
    end
end

% prescribed forces
[nforces,~] = size(PFCSet);
forces = zeros(nforces,3);
for i=1:nforces
    centinel = 0;
    vx = PFCSet(i,1:2);
    for j=1:nn
        if norm(coordinates(j,1:2)-vx) < 1.0e-12
            forces(i,1) = j;
            dof = PFCSet(i,3);
            value = PFCSet(i,4);
            forces(i,2) = dof;
            centinel = 1;
            forces(i,3) = value;
            break
        end
    end
    if centinel == 0
        error('PFC not found, please check!')
    end
end

stress = zeros(nel,1);
strain = zeros(nel,1);

end

