clc
clear all;
close all;
img = imread('c08_MR-T2.TIF');
figure,imshow(img);
img=im2double(img);
sigma = 3;
tic
res = interval_filtering(img, sigma);
toc
figure,imshow(res);
figure,imshow(img-res,[]);