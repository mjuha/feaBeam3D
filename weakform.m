function [fe,ke] = weakform(el,matNum,dirNum,xe,de)

global sideLoad MAT elements isPipe

% get material and section properties
prop = cell2mat(MAT(matNum));
E = prop(1); % Elastic modulus
G = prop(2); % Shear modulus
if isPipe %true
    % outer radius
    ro = prop(3)/2;
    % wall thickness
    tk = prop(4);
    % internal radius
    ri = ro - tk;
    %
    A = pi * ( ro^2 - ri^2 ); % cross sectional area
    I1 = (pi/4) * ( ro^4 - ri^4 ); % moment of iniertia 1
    I2 = I1; % moment of iniertia 2
    J = I1 + I2; % polar moment of inertia
else % false
    A = prop(3); % cross sectional area
    I1 = prop(4); % moment of iniertia 1
    I2 = prop(5); % moment of iniertia 2
    J = I1 + I2; % polar moment of inertia
end
% 1 point formula - degree of precision 1
% r = 0 w = 2
wt = 2; % weight

% compute element length
x1 = xe(1,1);
x2 = xe(2,1);
%
y1 = xe(1,2);
y2 = xe(2,2);
%
z1 = xe(1,3);
z2 = xe(2,3);
%
he = sqrt( (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2 );
% jacobian
jac = 0.5*he;

tol = 1.0e-14;
if jac < tol
    error('Negative or zero Jacobian, please check!')
end

% ------------------
% bending stiffness
% ------------------
dN1 = -1/he;
dN2 = 1/he;
% curvature matrix
Bb = zeros(2,12);
Bb(1,4) = dN1;
Bb(1,10) = dN2;
%
Bb(2,5) = dN1;
Bb(2,11) = dN2;

% bending properties matrix
Db = [E*I1 0;0 E*I2];
keb = Bb.' * Db * Bb * jac * wt;

% ------------------
% shear stiffness
% ------------------
% shear deformation matrix
N1 = 0.5; N2 = 0.5; % one-point quadrature
Bs = zeros(2,12);
Bs(1,1) = dN1;
Bs(1,5) = -N1;
Bs(1,7) = dN2;
Bs(1,11) = -N2;
%
Bs(2,2) = dN1;
Bs(2,4) = N1;
Bs(2,8) = dN2;
Bs(2,10) = N2;

% shear properties matrix
% Using the residual bending flexibity concept
C1 = 1 / ( 1/(G*A) + he^2/(12*E*I1) );
C2 = 1 / ( 1/(G*A) + he^2/(12*E*I2) );
Ds = [C1 0;0 C2];

%
kes = Bs.' * Ds * Bs * jac * wt;

% ------------------
% axial stiffness
% ------------------
% axial matrix
B = zeros(1,12);
B(1,3) = dN1;
B(1,9) = dN2;

% axial properties matrix
kea = B.' * (E*A) * B * jac * wt;

% ------------------
% torsional stiffness
% ------------------
% axial matrix
Bt = zeros(1,12);
Bt(1,6) = dN1;
Bt(1,12) = dN2;

% bending properties matrix
ket = Bt.' * (G*J) * Bt * jac * wt;

% stiffness matrix
ke = keb + kes + kea + ket;

ue = zeros(12,1);
for a=1:2 % loop over local nodes
    for i = 1:3 % loop over dimension
        ue(6*a-6+i) = de(i,a);
        ue(6*a-3+i) = de(i+3,a);
    end
end
% transform local to global
[ T ] = computeBeamDirection(dirNum,xe);
% transform global to local
ue = T.'*ue;

fe = zeros(12,1);
if size(sideLoad,1) > 0
    % compute side load
    n1 = elements(el,3:4);
    index = find( (sideLoad(:,1) == n1(1) ) & (sideLoad(:,2) == n1(2) ) );
    flag = size(index,1);
    if flag > 0
        face = sideLoad(index,3);
        value = sideLoad(index,4);
        % use one-point quadrature
        N1 = 0.5;
        N2 = 0.5;
        % we are assuming that distributed load act to the beam
        if face == 1
            fe(1) = -N1*value*jac*wt;
            fe(7) = -N2*value*jac*wt;
        else
            fe(2) = -N1*value*jac*wt;
            fe(8) = -N2*value*jac*wt;
        end
    end
end
fe = fe - ke * ue;
% tranform global to local
ke = T * ke * T.';
fe = T * fe;
end
