% For grayscale image fusion

close all;  clear all;  clc;
addpath functions
addpath ksvdbox13
addpath KSVD_Matlab_ToolBox
addpath ompbox10
addpath source_images

D=cell2mat(struct2cell(load('D_180.mat')));

A=imread('02 MR.bmp');  B1=imread('02 SPECT.bmp');     % input source images
figure,imshow(A);  figure,imshow(B1);
A=im2double(A); B1=im2double(B1);

sigma=20;     %  noise level: 0,10,20,30,... 
if sigma>0 
    v=sigma*sigma/(255*255); 
    A=imnoise(A,'gaussian',0,v);
    B1=imnoise(B1,'gaussian',0,v);
    figure,imshow(A); figure,imshow(B1);
end

tic
if size(A,3)>1
    A=rgb2gray(A);           
end

[hei, wid] = size(A);

%% RGB to YUV
B_YUV=ConvertRGBtoYUV(B1);   
B=B_YUV(:,:,1);            

%% 
lambda = 3;   npad = 12;  
[lowpass1, high1] = lowpass(A, lambda, npad);
[lowpass2, high2] = lowpass(B, lambda, npad);

%% 
sigma2 = 3;
structure1 = interval_filtering(lowpass1, sigma2);
structure2 = interval_filtering(lowpass2, sigma2);

texture1=lowpass1-structure1; texture2=lowpass2-structure2;

%%
overlap=7;   
C=0.002;       

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
texture11=SF(texture1,window_wide);   texture22=SF(texture2,window_wide);
map2=(texture11>=texture22);
fused_texture=(texture1.*map2+~map2.*texture2);  

%% 
F=fuse_high+fused_structure+fused_texture;

%% YUV to RGB
F_YUV=zeros(hei,wid,3);
F_YUV(:,:,1)=F;
F_YUV(:,:,2)=B_YUV(:,:,2);
F_YUV(:,:,3)=B_YUV(:,:,3);
final_F=ConvertYUVtoRGB(F_YUV);           
toc

figure,imshow(final_F);
final_fuse=uint8(final_F*255);


