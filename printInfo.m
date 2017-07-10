function printInfo(filename)

global nn nel neq nzmax

fprintf('****************************************************\n');
fprintf('            Welcome to FeaBeam3D\n');
fprintf('\n');
fprintf(' Copyright: Universidad de La Sabana - Colombia\n');
fprintf(' Author:    Mario J. Juha, Ph.D\n')
fprintf('****************************************************\n\n');

fprintf('  E X E C U T I O N  C O N T R O L  C A R D\n');
fprintf(' -------------------------------------------\n');
fprintf(' Input file name                  .............. %s\n',filename);
fprintf(' Number of nodal points           .............. %d\n',nn);
fprintf(' Number of beam elements          .............. %d\n',nel);
fprintf(' Number of equations              .............. %d\n',neq);
fprintf(' Sparse matrix                    .............. true\n');
fprintf(' Number of nz elements in matrix  .............. %d',nzmax);
fprintf('\n\n');


end

