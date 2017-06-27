function readMesh(mshfile)

global coordinates elements nn nel pointNode MAT BDSet

% ====================
% Open msh file
% ====================

fileID = fopen(mshfile,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end

% Get physical names (mandatory)
tline = fgetl(fileID);
if ~strcmp(tline,'$PhysicalNames')
    error('Input data MUST declare PhysicalNames. Please check.');
end
% get number of names
nNames = str2double(fgetl(fileID));
% get names
phyNames = zeros(nNames,2);
% each row contains: physical-dimension physical-number
for i=1:nNames
    tline = fgetl(fileID);
    phyNames(i,:) = sscanf(tline,'%d %d %*s');
end
fgetl(fileID); % discard this line
% Read nodes
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nn = str2double(tline);
%
coordinates = zeros(nn,3);
for i=1:nn
    tline = fgetl(fileID);
    coordinates(i,:) = sscanf(tline,'%*d %f %f %f');
end
fgetl(fileID); % discard this line
%
% read elements
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nelT = str2double(tline);
elementsT = cell(nelT,1);
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
for i=1:nelT
    tline = fgetl(fileID);
    C = str2double(strsplit(tline));
    switch C(2)
        case 15
            pointCount = pointCount + 1;
        case 1
            lineCount = lineCount + 1;
        otherwise
            error('Unknown element type. Please check.')
    end
    elementsT(i) = {C};
end
%close file
fclose(fileID);
% post-process data
nel = lineCount;
elements = zeros(nel,3); % store number of physical entity, element tag
pointNode = zeros(pointCount,2);
%
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
for i=1:nelT
    % get array
    v = elementsT{i};
    switch v(2)
        case 15
            pointCount = pointCount + 1;
            pointNode(pointCount,1) = v(4);
            pointNode(pointCount,2) = v(6);
        case 1
            lineCount = lineCount + 1;
            elements(lineCount,1) = v(4);
            elements(lineCount,2:3) = v(6:7);
        otherwise
            error('Unknown element type. Please check.')
    end
end
%
clearvars elementsT
end