% feaBeam3D.m
% This is the main file that implement a 3D linear beam elements
%
% Author: Dr. Mario J. Juha
% Date: 22/06/2017
% Mechanical Engineering
% Universidad de La Sabana
% Chia -  Colombia
%
% Clear variables from workspace
clearvars

global ID elements nn nel coordinates LM u forces MAT sideLoad 
global irow icol nzmax


% Specify file name
%filename = '\Users\marioju\Downloads\untitled.msh';
filename = '\\Client\C$\Users\marioju\Documents\Work\exampleBeam.inp';
% read data
outfile = readData(filename);

% % prepare data structure
% prepareData;
% 
% write original mesh
WriteVTKFile(outfile,0)
% 
% % =============================
% % Dimension the global matrices
% % =============================
% ndof = max(max(ID));
% K = zeros(ndof,ndof);
% F = zeros(ndof,1);
% 
% % ===========================
% % assembling stiffness matrix
% % ===========================
% for i=1:nel %loop over elements
%     xe = coordinates(elements(i,2:3),1:2);
%     de = u(:,elements(i,2:3));
%     E = MAT(elements(i,1),1);
%     A = MAT(elements(i,1),2);
%     [ke,fe] = weakform(xe,de,E,A);
%     for j=1:4
%         i_index = LM(j,i);
%         if (i_index > 0)
%             F(i_index) = F(i_index) + fe(j);
%             for k=1:4
%                 j_index = LM(k,i);
%                 if (j_index > 0)
%                     K(i_index,j_index) = K(i_index,j_index) + ke(j,k);
%                 end
%             end
%         end
%     end
% end
% 
% % assign point loads
% for i=1:size(forces,1)
%   i_index = ID(forces(i,2),forces(i,1));
%   F(i_index) = F(i_index) + forces(i,3);
% end
% 
% % solve system of equations
% u_bar = K\F;
% 
% for i=1:nn
%   index = ID(:,i);
%   for j=1:2
%     if ( index(j) ~= 0 )
%       u(j,i) = u_bar( index(j) );
%     end
%   end
% end
% 
% computeStressStrain
% 
% % write solution
% WriteVTKFile(outfile,1)
