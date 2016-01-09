close all; clear; clc;

filename = uigetfile({'*.txt;'});
[path, name, ext] = fileparts(filename); 

fid = fopen(filename);

tline = fgetl(fid);
m = str2double(tline);
tline = fgetl(fid);
n = str2double(tline);

Iarray = zeros(m,n) + 100;
L = 3; %blocks 7x7
counter = 0;

tline = (fgetl(fid));
while (fgetl(fid) ~= -1)
    
    lineScan = strsplit(tline);
    pixel = str2double(lineScan{1,1});
    value = str2double(lineScan{1,2});
    column = ceil(pixel/m);
    row = mod(pixel,n) + 1;
    Iarray(column, row) = value;
    counter = counter + 1;
    
    top = row - L;
    bottom = row + L;
    left = column - L;
    right = column + L;
    if (top < 1), top = 1; end
    if (bottom > n), bottom = n; end
    if (left < 1), left = 1; end
    if (right > m),right = m; end
    Iarray( top : bottom, left : right) = value;
    tline = (fgetl(fid));
end

fclose(fid);

I = uint8(Iarray);
imshow(I);
set(gca,'position',[0 0 1 1],'units','normalized')

compressionRatio = counter / (m*n);
disp(compressionRatio);

% imwrite(I, [name 'ChaoticScan' '.png']);
