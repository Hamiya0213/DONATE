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
close all
clc 
clear
addpath(genpath(pwd))

i = 1;
for shot_num = [4, 6, 8, 10]

try
    load(['Spine_', num2str(shot_num), 'shot.mat']);
catch
    error('Data file not found, please go to https://github.com/Hamiya0213/DONATE to download');
end


[Nx, Ny, Ncoil, Nshot] = size(Y_tmp); % Nx:RO Ny:PE Ncoil:Channel Nshot:Shot

%% Pre-reconstruction: MUSSELS
% Chen Qian, Zi Wang, et al., ﻿A Paired Phase and Magnitude Reconstruction for Advanced Diffusion-Weighted Imaging, IEEE Transactions on Biomedical Engineering, 2023, 70(12): 3425-3435.
% ﻿M. Mani, M. Jacob, D. Kelley, and V. Magnotta, “Multi-shot sensitivity-encoded diffusion data recovery using structured low-rank matrix completion (MUSSELS),” Magn.Reson. Med., vol. 78, no. 2, pp. 494-507, 2017.
Par_M.isShow = true;
[img_M] = Pre_recon2(Y_tmp, csm, Par_M);
[U_Pre, V_Pre] = Extract_Subspace(img_M, Nx, Ny);

%% Reconstruction: DONATE
Par_DONATE.isShow = true;
[Mag_DONATE_M, Phase_DONATE_M] = Solver_DONATE(Y_tmp,csm,Par_DONATE, U_Pre, V_Pre);

Results(:,:,i) = imresize(Mag_DONATE_M, [252, 180]);
i = i + 1;
end

%% Figure
figure(10);
subplot(1, 4, 1);
imshow(rot90(abs(Results(:, :, 1)), 2), []);
title('4shot');

subplot(1, 4, 2);
imshow(rot90(abs(Results(:, :, 2)), 2), []);
title('6shot');

subplot(1, 4, 3);
imshow(rot90(abs(Results(:, :, 3)), 2), []);
title('8shot');

subplot(1, 4, 4);
imshow(rot90(abs(Results(:, :, 4)), 2), []);
title('10shot');
