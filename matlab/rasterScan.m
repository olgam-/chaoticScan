close all; clear; clc;

% filename = '\files\lena128raster1368.txt';
% filename = '\files\puppy128raster819.txt';

filename = uigetfile({'*.txt;'});
[path, name, ext] = fileparts(filename); 

fid = fopen(filename);

tline = fgetl(fid);
m = str2double(tline);
tline = fgetl(fid);
n = str2double(tline);

flag = 0;
Iarray = zeros(m,n);

for i = 1 : m
    for j = 1 : n
        tline = (fgetl(fid));
        if tline == -1
            flag = 1;
            break
        else 
            lineScan = strsplit(tline);
            value = str2double(lineScan{1,1});
            Iarray(j,i) = value;
        end
    end
    if flag == 1
        break
    end
 end


fclose(fid);

I = uint8(Iarray);
imshow(I);
set(gca,'position',[0 0 1 1],'units','normalized')

% imwrite(I, [name 'RasterScan' '.png']);
