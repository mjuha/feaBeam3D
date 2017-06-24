function [outfile] = readData(filename)

% global variables
global coordinates elements nn nel pointNode MAT DBCSet PFCSet
global BDSet NBCSet

% Open file
fileID = fopen(filename,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end

% get mesh input file
tline = fgetl(fileID);
tmp = strsplit(tline);
len = length(tmp); 
if len > 4
    % concatenate name
    for i=4:len-1
        mshfile = tmp{i};
        s1 = tmp{i+1};
        mshfile = strcat(mshfile,{' '},s1);
    end
else
   mshfile = tmp{4}; 
end
% get output file location
tline = fgetl(fileID);
tmp = strsplit(tline);
len = length(tmp); 
if len > 3
    % concatenate name
    for i=3:len-1
        outfile = tmp{i};
        s1 = tmp{i+1};
        outfile = strcat(outfile,{' '},s1);
    end
else
   outfile = tmp{3}; 
end
% get direction set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nds = str2double(tmp(4)); % number of direction sets to read
dirSet = cell(nds,2);
if nds == 0
    fgetl(fileID); % dummy line
else
    for i=1:nds
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        phyN = str2double(tmp(1)); % physical entity number
        dirSet(i,:) = {phyN, tmp{2}};
    end
end
% get material set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nms = str2double(tmp(4)); % number of material sets to read
matSet = cell(nms,2);
if nms == 0
    fgetl(fileID); % dummy line
else
    for i=1:nms
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        phyN = str2double(tmp(1)); % physical entity number
        matSet(i,:) = {phyN, tmp{2}};
    end
end
% get side set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nss = str2double(tmp(4)); % number of side sets to read
sideSet = cell(nss,2);
if nss == 0
    fgetl(fileID); % dummy line
else
    for i=1:nss
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        phyN = str2double(tmp(1)); % physical entity number
        sideSet(i,:) = {phyN, tmp{2}};
    end
end
% read Dirichlet BCs (may be displacements or rotations)
tline = fgetl(fileID);
tmp = strsplit(tline);
ndbc = str2double(tmp(3)); % number of DBC to read
DBCSet = zeros(ndbc,6);
for i=1:ndbc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    DBCSet(i,1:3) = str2double(tmp(1:3));
    dof = sscanf(tmp{4},'%[DR]');
    dir = sscanf(tmp{5},'%[XYZ]');
    value = str2double(tmp(6)); % value to assign
    if strcmp(dof,'D')
        DBCSet(i,4) = 1;
    elseif strcmp(dof,'R')
        DBCSet(i,4) = 2;
    else
        error('DOF must be D or R, please check')
    end
    if strcmp(dir,'X')
        DBCSet(i,5) = 1;
        DBCSet(i,6) = value;
    elseif strcmp(dir,'Y')
        DBCSet(i,5) = 2;
        DBCSet(i,6) = value;
    elseif strcmp(dir,'Z')
        DBCSet(i,5) = 3;
        DBCSet(i,6) = value;
    else
        error('Direction must be X, Y or Z, please check')
    end
end
% read point forces and moments BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
npfc = str2double(tmp(3)); % number of point force to read
PFCSet = zeros(npfc,6);
for i=1:npfc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    PFCSet(i,1:3) = str2double(tmp(1:3));
    dof = sscanf(tmp{4},'%[FM]');
    dir = sscanf(tmp{5},'%[XYZ]');
    value = str2double(tmp(6)); % value to assign
    if strcmp(dof,'F')
        PFCSet(i,4) = 1;
    elseif strcmp(dof,'M')
        PFCSet(i,4) = 2;
    else
        error('Loads must be F or M, please check')
    end
    if strcmp(dir,'X')
        PFCSet(i,5) = 1;
        PFCSet(i,6) = value;
    elseif strcmp(dir,'Y')
        PFCSet(i,5) = 2;
        PFCSet(i,6) = value;
    elseif strcmp(dir,'Z')
        PFCSet(i,5) = 3;
        PFCSet(i,6) = value;
    else
        error('Direction must be X, Y or Z, please check')
    end
end
% read beam direction set
tline = fgetl(fileID);
tmp = strsplit(tline);
nbds = str2double(tmp(3)); % number of beam directions to read
BDSet = cell(nbds,4);
for i=1:nbds
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    name = tmp{1};
    vec = str2double(tmp(2:4));
    BDSet(i,:) = {name, vec(1), vec(2), vec(3)};
    % check that association is correct (input file only)
    found = false;
    for j=1:nds
        if strcmp(name,dirSet{j,2})
            found = true;
            break;
        end
    end
    if ~found
        error('Verify direction set association, name not found')
    end
end
% read distributed load
tline = fgetl(fileID);
tmp = strsplit(tline);
nnbc = str2double(tmp(3)); % number of NBC to read
NBCSet = cell(nnbc,3);
if nnbc == 0
    fgetl(fileID); %dummy line
else
    for i=1:nnbc
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        name = tmp{4};
        dof = sscanf(tmp{6},'%[face]');
        if ~strcmp(dof,'face')
            error('DL must specify face, please check')
        end
        face = str2double(tmp(7)); % face
        if (face ~= 1) || (face ~= 2)
            error('Face must be 1 or 2, please check')
        end
        value = str2double(tmp(8)); % value to assign
        NBCSet(i,:) = {name, face, value};
        % check that association is correct (input file only)
        found = false;
        for j=1:nss
            if strcmp(name,sideSet{j,2})
                found = true;
                break;
            end
        end
        if ~found
            error('Verify side set association, name not found')
        end
    end
end

% 
% %Read material properties
% % get next line and discard it
% fgetl(fileID);
% tline = fgetl(fileID);
% tmp = strsplit(tline);
% nmat = str2double(tmp(3)); % number of materials
% MAT = zeros(nmat,2);
% 
% for i=1:nmat
%     tline = fgetl(fileID);
%     tmp = strsplit(tline);
%     MAT(i,1) = str2double(tmp(3)); % Elastic modulus
%     tline = fgetl(fileID);
%     tmp = strsplit(tline);
%     MAT(i,2) = str2double(tmp(2)); % area
% end
% fclose(fileID);
% 
% % ====================
% % Open msh file
% % ====================
% 
% fileID = fopen(mshfile,'r');
% 
% % get first three lines and discard them
% for i=1:3
%     fgetl(fileID);
% end
% 
% % Get physical names (mandatory)
% tline = fgetl(fileID);
% if ~strcmp(tline,'$PhysicalNames')
%     error('Input data MUST declare PhysicalNames. Please check.');
% end
% % get number of names
% nNames = str2double(fgetl(fileID));
% % get names
% phyNames = zeros(nNames,2);
% % each row contains: physical-dimension physical-number
% for i=1:nNames
%     tline = fgetl(fileID);
%     phyNames(i,:) = sscanf(tline,'%d %d %*s');
% end
% fgetl(fileID); % discard this line
% % Read nodes
% fgetl(fileID); % discard this line
% tline = fgetl(fileID);
% nn = str2double(tline);
% %
% coordinates = zeros(nn,3);
% for i=1:nn
%     tline = fgetl(fileID);
%     coordinates(i,:) = sscanf(tline,'%*d %f %f %f');
% end
% fgetl(fileID); % discard this line
% %
% % read elements
% fgetl(fileID); % discard this line
% tline = fgetl(fileID);
% nelT = str2double(tline);
% elementsT = cell(nelT,1);
% % count number of 1-node point
% pointCount = 0;
% % count number of 2-node line
% lineCount = 0;
% for i=1:nelT
%     tline = fgetl(fileID);
%     C = str2double(strsplit(tline));
%     switch C(2)
%         case 15
%             pointCount = pointCount + 1;
%         case 1
%             lineCount = lineCount + 1;
%         otherwise
%             error('Unknown element type. Please check.')
%     end
%     elementsT(i) = {C};
% end
% %close file
% fclose(fileID);
% % post-process data
% nel = lineCount;
% elements = zeros(nel,3); % store number of physical entity, element tag
% pointNode = zeros(pointCount,2);
% %
% % count number of 1-node point
% pointCount = 0;
% % count number of 2-node line
% lineCount = 0;
% for i=1:nelT
%     % get array
%     v = elementsT{i};
%     switch v(2)
%         case 15
%             pointCount = pointCount + 1;
%             pointNode(pointCount,1) = v(4);
%             pointNode(pointCount,2) = v(6); 
%         case 1
%             lineCount = lineCount + 1;
%             elements(lineCount,1) = v(4);
%             elements(lineCount,2:3) = v(6:7);
%         otherwise
%             error('Unknown element type. Please check.')
%     end
% end
% %
clearvars elementsT

end