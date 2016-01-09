close all; clear; clc;

% filename = 'C:\Users\Olga\Desktop\chaoticScan\images\lena128.png';
filename = uigetfile({'*.jpg;*.tif;*.png;*.gif'});
[path, name, ext] = fileparts(filename); 
I = imread(filename);

% figure(1), imshow(I);

[a, b, c] = size(I);
if c == 3
    I = rgb2gray(I);
end

% figure(2), imshow(I);

%% Convert to text

fid = fopen([name '.txt'], 'wt');
fprintf(fid, '%d\n', a);
fprintf(fid, '%d\n', b);
fprintf(fid, '%d\n', I);
fclose(fid);

