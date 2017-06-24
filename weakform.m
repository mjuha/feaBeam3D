function [ke,fe] = weakform(xe,de,E,A)

% initialize stiffness matrix and force vector
x1 = xe(1,1);
x2 = xe(2,1);
%
y1 = xe(1,2);
y2 = xe(2,2);

%
le = sqrt( (x2-x1)^2 + (y2-y1)^2 );
l = (x2 - x1)/le;
m = (y2-y1)/le;
lm = l*m;

%
ke = (E*A/le)*[l^2 lm -l^2 -lm; lm m^2 -lm -m^2; -l^2 -lm l^2 lm; ...
    -lm -m^2 lm m^2];
%

ue = zeros(4,1);
for i=1:2 % loop over local nodes
    ue(2*i-1) = de(1,i);
    ue(2*i) = de(2,i);
end

fe = -ke*ue;


end
