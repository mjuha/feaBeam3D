function computeStressStrain

global elements u nel coordinates MAT isPipe
global axialForce bendingMoment torsionalForce shearForce
global principalStress maxShearStress VonMisesStress

for i=1:nel
    matNum = elements(i,1);
    dirNum = elements(i,2);
    % get material and section properties
    if iscell(MAT(matNum))
        prop = cell2mat(MAT(matNum));
    else
        prop = MAT(matNum);
    end
    E = prop(1); % Elastic modulus
    G = prop(2); % Shear modulus
    if isPipe %true
        alpha = prop(5); % Coef. thermal expansion
        dT = prop(6); % temperature change
        % outer radius
        ro = prop(3)/2;
        % wall thickness
        tk = prop(4);
        % internal radius
        ri = ro - tk;
        %
        A = pi * ( ro^2 - ri^2 ); % cross sectional area
        I1 = (pi/4) * ( ro^4 - ri^4 ); % moment of inertia 1
        I2 = I1; % moment of inertia 2
        J = I1 + I2; % polar moment of inertia
    else % false
        A = prop(3); % cross sectional area
        I1 = prop(4); % moment of iniertia 1
        I2 = prop(5); % moment of iniertia 2
        J = I1 + I2; % polar moment of inertia
        alpha = prop(6); % Coef. thermal expansion
        dT = prop(7); % temperature change
    end
    
    % 1 point formula - degree of precision 1
    % r = 0 w = 2
    xe = coordinates(elements(i,3:4),:);
    de = u(:,elements(i,3:4));
    %
    ue = zeros(12,1);
    for a=1:2 % loop over local nodes
        for j = 1:3 % loop over dimension
            ue(6*a-6+j) = de(j,a);
            ue(6*a-3+j) = de(j+3,a);
        end
    end
    %
    [ T ] = computeBeamDirection(dirNum,xe);
    % transform global to local
    ue = T.'*ue;
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
    % ------------
    % bending
    % ------------
    dN1 = -1/he;
    dN2 = 1/he;
    % curvature matrix
    Bb = zeros(2,12);
    Bb(1,4) = dN1;
    Bb(1,10) = dN2;
    %
    Bb(2,5) = dN1;
    Bb(2,11) = dN2;
    %
    kappa = Bb*ue; % curvature (2 x 1)
    if isPipe % true
        bendingMoment1 = E*kappa(1)*ro; % maximum bending stress
        bendingMoment2 = -E*kappa(2)*ro; % maximum bending stress
    else
        bendingMoment(i,1) = E*I1*kappa(1);
        bendingMoment(i,2) = -E*I2*kappa(2);
    end
    %
    % ----------
    % shear
    % ----------
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
    %
    shearStrain = Bs*ue; % shear strain (2 x 1)
    if isPipe % true
        C = (ro^2 + 2*ro*ri + ri^2)/(ro^2+ri^2);
        shearForce1 = (4/3)*G*shearStrain(1)*C;
        shearForce2 = (4/3)*G*shearStrain(2)*C;
    else
        shearForce(i,1) = G*A*shearStrain(1);
        shearForce(i,1) = G*A*shearStrain(2);
    end
    %
    % ----------
    % axial
    % -----------
    % axial matrix
    B = zeros(1,12);
    B(1,3) = dN1;
    B(1,9) = dN2;
    %
    axialStrain = B*ue - alpha * dT; % axial strain (1 x 1)
    if isPipe % true
        axialForce1 = E*axialStrain;
    else
        axialForce(i) = E*A*axialStrain;
    end
    %
    % ------------
    % torsional
    % ------------
    % axial matrix
    Bt = zeros(1,12);
    Bt(1,6) = dN1;
    Bt(1,12) = dN2;
    %
    torsionalStrain = Bt*ue; % torsional strain (1 x 1)
    if isPipe % true
        torsionalForce1 = G*torsionalStrain*ro;
    else
        torsionalForce(i) = G*J*torsionalStrain;
    end
    % compute principal stress if pipe
    if isPipe
        % evaluate four critical points in cross sectional area of the pipe
        % point A
        sigma = axialForce1 + bendingMoment1;
        tau = torsionalForce1 + shearForce1;
        % principal stress
        s1 = 0.5*sigma + sqrt( (0.5*sigma)^2 + tau^2 );
        s2 = 0.5*sigma - sqrt( (0.5*sigma)^2 + tau^2 );
        tau_max = 0.5*(s1-s2);
        % point B
        sigma = axialForce1 + bendingMoment2;
        tau = torsionalForce1 + shearForce2;
        % principal stress
        s1t = 0.5*sigma + sqrt( (0.5*sigma)^2 + tau^2 );
        s2t = 0.5*sigma - sqrt( (0.5*sigma)^2 + tau^2 );
        tau_max_t = 0.5*(s1t-s2t);
        %
        s1 = max(s1,s1t);
        s2 = max(s2,s2t);
        tau_max = max(tau_max,tau_max_t);
        % point C
        sigma = axialForce1 - bendingMoment1;
        tau = -torsionalForce1 - shearForce1;
        % principal stress
        s1t = 0.5*sigma + sqrt( (0.5*sigma)^2 + tau^2 );
        s2t = 0.5*sigma - sqrt( (0.5*sigma)^2 + tau^2 );
        tau_max_t = 0.5*(s1t-s2t);
        %
        s1 = max(s1,s1t);
        s2 = max(s2,s2t);
        tau_max = max(tau_max,tau_max_t);
        % point D
        sigma = axialForce1 - bendingMoment2;
        tau = -torsionalForce1 - shearForce2;
        % principal stress
        s1t = 0.5*sigma + sqrt( (0.5*sigma)^2 + tau^2 );
        s2t = 0.5*sigma - sqrt( (0.5*sigma)^2 + tau^2 );
        tau_max_t = 0.5*(s1t-s2t);
        %
        s1 = max(s1,s1t);
        s2 = max(s2,s2t);
        tau_max = max(tau_max,tau_max_t);
        %
        principalStress(i,1) = s1;
        principalStress(i,2) = s2;
        maxShearStress(i) = tau_max;
        VonMisesStress(i) = sqrt( 0.5*( (s1-s2)^2 + s2^2 + s1^2 ) );
    end
    
end

end