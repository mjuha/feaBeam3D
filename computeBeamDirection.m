function [ T ] = computeBeamDirection(dirNum,xe)

global BDSet

% get global direction (orientation) vector
if BDSet(dirNum)
    vec = cell2mat(BDSet(dirNum));
else
    vec = BDSet(dirNum);
end
% compute the local unit basis vector along the local z-axis
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

epz = (1/he) * [x2 - x1, y2 - y1, z2 - z1];

% compute the local unit basis vector along the local x-axis
v1 = dot(vec,epz) * epz; % parallel vector along local z-axis
v2 = vec - v1; % vector along the local x-axis
if norm(v2) < 1.0e-14
    error('Check beam direction. It looks like you are specifying a vector parallel to a beam.');
end
epx = v2/norm(v2); % unit vector

% compute the local unit basis vector along the local y-axis
epy = cross(epz,epx);

% transformation matrix
te = zeros(3); % 3 x 3 (local)
for i = 1:3
    e1 = zeros(1,3);
    e1(i) = 1;
    te(i,1) = dot(e1,epx);
    te(i,2) = dot(e1,epy);
    te(i,3) = dot(e1,epz);
end

% transformation matrix
T = zeros(12); % 12 x 12 (global)
%
T(1:3,1:3) = te;
T(4:6,4:6) = te;
T(7:9,7:9) = te;
T(10:12,10:12) = te;


end

