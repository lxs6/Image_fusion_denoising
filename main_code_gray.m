% For functional medical image fusion

close all;  clear all;  clc;
addpath functions
addpath ksvdbox13
addpath KSVD_Matlab_ToolBox
addpath ompbox10

D=cell2mat(struct2cell(load('D_180.mat')));

A=imread('01 MR-T1.tif');  B=imread('01 MR-T2.tif');     % input source images
figure,imshow(A);  figure,imshow(B);

if size(A,3)>1
    A=rgb2gray(A);     
end
if size(B,3)>1
    B=rgb2gray(B);           
end

A = im2double(A);   B = im2double(B);    

sigma=0;  % noise level: 0,10,20,30,...
if sigma>0 
    v=sigma*sigma/(255*255);  
    A=imnoise(A,'gaussian',0,v);
    B=imnoise(B,'gaussian',0,v);
    figure;imshow(A);  figure;imshow(B);
end

tic
%% 
lambda =3;   npad = 12; 
[lowpass1, high1] = lowpass(A, lambda, npad);
[lowpass2, high2] = lowpass(B, lambda, npad);

%% 
sigma2 = 3;
structure1 = interval_filtering(lowpass1, sigma2);
structure2 = interval_filtering(lowpass2, sigma2);
texture1=lowpass1-structure1;
texture2=lowpass2-structure2;

%%
overlap=7;    C=0.0035;     
if sigma==0
    epsilon=0.01;    
else
    epsilon=0.05++8*C*sigma;
end
fuse_high=sparse_fusion3(high1,high2,D,overlap,epsilon);

%% 
map=abs(structure1>structure2);
fused_structure=(structure1.*map+~map.*structure2); 

%% 
window_wide=43;
texture11=SF(texture1,window_wide); 
texture22=SF(texture2,window_wide);
map2=(texture11>=texture22);
fused_texture=(texture1.*map2+~map2.*texture2);  

%% 
Fuse_img=fuse_high+fused_structure+fused_texture;
toc

final_fuse=uint8(Fuse_img*255);
figure,imshow(final_fuse);

