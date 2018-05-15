function [outfile] = readData(filename)

% global variables
global MAT DBCSet PFCSet BDSet NBCSet isPipe

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
% get flag for pipe element
tline = fgetl(fileID);
tmp = strsplit(tline);
if strcmp(tmp{3},'YES')
    isPipe = true;
elseif strcmp(tmp{3},'NO')
    isPipe = false;
else
    error('Is pipe must be YES or NOT, please check!')
end
% get direction set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nds = str2double(tmp(4)); % number of direction sets to read
keySet = cell(1,nds);
valueSet = zeros(1,nds);
if nds == 0
    fgetl(fileID); % dummy line
else
    for i=1:nds
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        keySet(i) = tmp(2);
        valueSet(i) = str2double(tmp(1)); % physical entity number
    end
    dirSet = containers.Map(keySet,valueSet);
end
% get material set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nms = str2double(tmp(4)); % number of material sets to read
keySet = cell(1,nms);
valueSet = zeros(1,nms);
if nms == 0
    fgetl(fileID); % dummy line
else
    for i=1:nms
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        keySet(i) = tmp(2); % physical name
        valueSet(i) = str2double(tmp(1)); % physical entity number
    end
    matSet = containers.Map(keySet,valueSet);
end
% get side set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nss = str2double(tmp(4)); % number of side sets to read
keySet = cell(1,nss);
valueSet = zeros(1,nss);
if nss == 0
    fgetl(fileID); % dummy line
else
    for i=1:nss
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        keySet(i) = tmp(2); % physical entity name
        valueSet(i) = str2double(tmp(1)); % physical entity number
    end
    sideSet = containers.Map(keySet,valueSet);
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
if npfc == 0
    fgetl(fileID); % dummy line
else
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
end
% read beam direction set
tline = fgetl(fileID);
tmp = strsplit(tline);
nbds = str2double(tmp(3)); % number of beam directions to read
nameKey = zeros(1,nbds);
valueSet = cell(1,nbds);
if nbds == 0
    fgetl(fileID); % dummy line
else
    for i=1:nbds
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        name = tmp{1};
        if ~isKey(dirSet,name)
            error('Verify direction set association, name not found')
        end
        nameKey(i) = dirSet(name);
        vec = str2double(tmp(2:4)); % unit vector - direction
        valueSet(i) = {vec};
    end
    BDSet = containers.Map(nameKey,valueSet);
end
% read distributed load
tline = fgetl(fileID);
tmp = strsplit(tline);
nnbc = str2double(tmp(3)); % number of NBC to read
nameKey = zeros(1,nnbc);
valueSet = cell(1,nnbc);
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
        if (face ~= 1) && (face ~= 2)
            error('Face must be 1 or 2, please check')
        end
        value = str2double(tmp(9)); % value to assign
        nameKey(i) = sideSet(name);
        vec = [face value];
        valueSet(i) = {vec};
    end
    NBCSet = containers.Map(nameKey,valueSet);
end
% Read material properties
% get next line and discard it
fgetl(fileID);
tline = fgetl(fileID);
tmp = strsplit(tline);
nmat = str2double(tmp(3)); % number of materials
propKey = cell(1,nmat);
nameKey = zeros(1,nmat);
for i=1:nmat
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    name = tmp{2};
    if ~isKey(matSet,name)
        error('Verify material set association, name not found')
    end
    nameKey(i) = matSet(name);
    % elastic modulus
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    E = str2double(tmp(3));
    % Shear modulus
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    G = str2double(tmp(3));
    % Coef. Thermal expansion
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    alpha = str2double(tmp(3));
    % Temperature change
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    dT = str2double(tmp(3));
    if isPipe % true
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        % pipe outer diameter
        do = str2double(tmp(4));
        % wall thickness
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        tk = str2double(tmp(3));
        %
        prop1 = [E G do tk alpha dT];
    else % false
        % Area
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        A = str2double(tmp(2));
        % Moment of inertia 1
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        I1 = str2double(tmp(5));
        % Moment of inertia 2
        tline = fgetl(fileID);
        tmp = strsplit(tline);
        I2 = str2double(tmp(5));
        %
        prop1 = [E G A I1 I2 alpha dT];
    end
    propKey(i) = {prop1};
    MAT = containers.Map(nameKey,propKey);
end
fclose(fileID);
% read mesh
readMesh(mshfile)
% prepare data
prepareData

end