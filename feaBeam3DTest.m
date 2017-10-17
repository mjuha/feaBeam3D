% test feaBeam3D

% preconditions

%% Test 1: VM12
normDisp = 1.21804;
normRot = 0.0109493;
tol = 1.0e-5;
filename = '\\Client\C$\Users\marioju\Documents\feaBeam3D\examples\VM12\examplePipe.inp';
feaBeam3D(filename,normDisp,normRot,tol)
clear global

%% Test 1: VM2
normDisp = 0.162442;
normRot = 3.46945e-19;
tol = 1.0e-5;
filename = '\\Client\C$\Users\marioju\Documents\feaBeam3D\examples\VM2\vm2.inp';
feaBeam3D(filename,normDisp,normRot,tol)
clear global