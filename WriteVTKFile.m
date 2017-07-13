function WriteVTKFile( outfiledest,istep  )
% ======================================================================
% This file is part of feaTruss2D.

%    feaTruss2D is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as 
%    published by the Free Software Foundation, either version 3 of the 
%    License, or (at your option) any later version.

%    feaTruss2D is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.

%    You should have received a copy of the GNU Lesser General Public 
%    License along with feaTruss2D.  
%    If not, see <http://www.gnu.org/licenses/>.
%
% Brief explanation:
%
%
% Author: Mario J. Juha, Ph.D
% Date: 
% 
% =====================================================================

global coordinates elements nn nel u isPipe
global axialForce bendingMoment torsionalForce shearForce
global principalStress maxShearStress VonMisesStress

if istep < 10
    % file name
    fname = [outfiledest 'output000' num2str(istep) '.vtk'];
elseif istep < 100
    % file name
    fname = [outfiledest 'output00' num2str(istep) '.vtk'];
elseif istep < 1000
    % file name
    fname = [outfiledest 'output0' num2str(istep) '.vtk'];
else
    % file name
    fname = [outfiledest 'output' num2str(istep) '.vtk'];
end

% open file
fid = fopen(fname, 'w');
fprintf(fid, '# vtk DataFile Version 3.8\n');
fprintf(fid, 'Mesh\n');
fprintf(fid,'ASCII\n');
fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');
fprintf(fid, '%s %d %s\n','POINTS ', nn, 'float');
for i=1:nn
    fprintf(fid, '%g  %g  %g\n', coordinates(i,1), coordinates(i,2), ...
        coordinates(i,3));
end
fprintf(fid, '%s %d %d\n','CELLS ', nel, 3*nel);
for i=1:nel
    fprintf(fid, '%d %d %d\n',2, elements(i,3:4)-1);
end
fprintf(fid, '%s %d\n','CELL_TYPES ', nel);
for i=1:nel
    fprintf(fid, '%d\n', 3);
end
fprintf(fid, '%s %d\n', 'POINT_DATA ', nn);
fprintf(fid, 'VECTORS DISP float\n');
for i=1:nn
    fprintf(fid, '%g %g %g\n',u(1,i),u(2,i),u(3,i));
end
fprintf(fid, 'VECTORS ROT float\n');
for i=1:nn
    fprintf(fid, '%g %g %g\n',u(4,i),u(5,i),u(6,i));
end
fprintf(fid, '%s %d\n', 'CELL_DATA ', nel);
if isPipe %true
    fprintf(fid, 'VECTORS PRINCIPAL_STRESS float\n');
    for i=1:nel
        fprintf(fid, '%g %g %g\n',principalStress(i,1),principalStress(i,2),0.0);
    end
    fprintf(fid, 'SCALARS MAX_SHEAR_STRESS float 1\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    for i=1:nel
        fprintf(fid, '%g\n',maxShearStress(i));
    end
    fprintf(fid, 'SCALARS VON_MISES_STRESS float 1\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    for i=1:nel
        fprintf(fid, '%g\n',VonMisesStress(i));
    end
else
    fprintf(fid, 'VECTORS FORCES float\n');
    for i=1:nel
        fprintf(fid, '%g %g %g\n',shearForce(i,1),shearForce(i,2),axialForce(i));
    end
    fprintf(fid, 'VECTORS MOMENTS float\n');
    for i=1:nel
        fprintf(fid, '%g %g %g\n',bendingMoment(i,1),bendingMoment(i,2),torsionalForce(i));
    end
end
% close file
fclose(fid);


end

