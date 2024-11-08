%% Chen Q., Mingyang H., et al., Fast and Ultra-high Shot Diffusion MRI Images Reconstruction with Self-adaptive Hankel Subspace.
%% Created by Mingyang Han
%% Corresponding Author: Xiaobo Qu
%% Homepage: http://csrc.xmu.edu.cn
%% Email: quxiaobo <|at|> xmu.edu.cn
%% Affiliations: Computational Sensing Group (CSG), Departments of Electronic Science, Xiamen University, Xiamen 361005, China
%% All rights are reserved by CSG.
%% Formal reconstruction in k-k space, along FE

%% Input: Solver_DONATE
%%       Y: Multi-coil multi-shot data; Y = [FE, PE, Ncoil, Nshot] 
%%       csm: Coil sensitvity map (extra scan)
%%       params: Important parameters
%% Output:
%%       magnitudeImage: Reconstructed image amplitude
%%       phaseEstimate: Estimated phase
clear
close all
clc
addpath(genpath(pwd))

%% load data
try
    load data_simu.mat
catch
    error('Data file not found, please go to https://github.com/Hamiya0213/DONATE to download');
end

mask_img = getMask(Image_Brain_15dir); 

%% make multishot data
SNR = 10;
Y = make_multishot_data(Image_Brain_15dir, csm, phase_8shot, SNR);
[Nx, Ny, Ncoil, Nshot] = size(Y); % Nx:RO Ny:PE Ncoil:Channel Nshot:Shot

%% Pre-recon
% Chen Qian, Zi Wang, et al., ﻿A Paired Phase and Magnitude Reconstruction for Advanced Diffusion-Weighted Imaging, IEEE Transactions on Biomedical Engineering, 2023, 70(12): 3425-3435.
% ﻿M. Mani, M. Jacob, D. Kelley, and V. Magnotta, “Multi-shot sensitivity-encoded diffusion data recovery using structured low-rank matrix completion (MUSSELS),” Magn.Reson. Med., vol. 78, no. 2, pp. 494-507, 2017.
Pre_params.isShow = true;
[Img] = Pre_recon1(Y,csm, Pre_params);
[U_Pre, V_Pre] = Extract_Subspace(Img, Nx, Ny);

%% Reconstruction: DONATE
Par_DONATE.isShow = true;
[Mag_DONATE, Phase_DONATE] = Solver_DONATE(Y, csm,Par_DONATE, U_Pre, V_Pre);

%% Evaluation: PSNR
res_DONATE = Mag_DONATE/max(abs(Mag_DONATE(:)));
PSNR_DONATE = PSNR(res_DONATE.*mask_img, Image_Brain_15dir);

%% Figure
close all
figure(10), imshow(rot90(abs(rot90(Mag_DONATE,3)),3),[])
