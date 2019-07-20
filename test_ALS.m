% sDR algorithm test
% Minh Pham, UCLA mathematics 

%%
addpath('functions\');
addpath('data\');
%% data inputs
load NS_160312212_processed.mat
Patterns = new_diffpats.^2;
rng(1,'twister');
nPats = size(new_diffpats,3);
set = 1:nPats;
% take the top part of the image
index = positions(:,2)<-160 & positions(:,2)>-700;index = set(index);
npats = size(index,2);
% take 40% of the top part data
index_set = randperm(npats,npats*.4);
index = index(index_set);

ePIE_inputs.FileName = 'DR_test';
ePIE_inputs.Patterns = Patterns(:,:,index);
ePIE_inputs.GpuFlag = 0;
ePIE_inputs.Positions = positions(index,:);
ePIE_inputs.PixelSize = 1;%pixel_size*1e9/3;
ePIE_inputs.InitialObj = 0;
ePIE_inputs.ApRadius = 10;
ePIE_inputs.InitialAp = 0;
ePIE_inputs.updateAp = 1;
ePIE_inputs.showim = 1;
ePIE_inputs.Iterations = 300;

%% ePIE reconstruction
% syntax: ePIE(ePIE_inputs, beta_obj, beta_ap);
% beta_obj: values in (0,1]: step size of gradient descent on object
% beta_ap : values in (0,1]: step size of gradient descent on aperture

[big_obj,aperture,fourier_error,initial_obj,initial_aperture] = ePIE(ePIE_inputs,1,0.05);

%% rPIE reconstruction
% syntax: ePIE(ePIE_inputs, beta_obj_c=0.05, beta_ap);
% beta_obj_c = 1-beta_obj: their paper use opposite meaning

[big_obj2,aperture2,fourier_error2,initial_obj2,initial_aperture2] = rPIE(ePIE_inputs,0.1,0.05);

%% DR reconstruction
% syntax with default parameters: 
% DRb[beta_obj, beta_ap, momentum, probeNormflag=0, init_weight=0.1, final_weight=0.4, order=4, semi_implicit_P=0]
%
% beta_obj: step size of gradient descent on object
%           take values in (0,1) RESTRICTEDLY
%
% beta_ap : step size of gradient descent on aperture
%           take values in (0,1]: 
%
% momentum: take values in [0,1]:
%           0 means no momentum, 
%           1 means reflection
%
% probeNormflag: normalize probe norm if = 1
%                this is helpful if we want unique solution
%
% intial_weight, final weight, order: parameters determine the relaxation
%
% semi_implicit_P: flag whether to apply semi implicit method on aperture
%
% for simplicity, you only need to provide inputs for the first 3 parameters: beta_obj, beta_ap, momentum
%
% DR is very sensitive with momentum parameter.
% Hence sir-DR will run with momentum=0 in the first 20 iterations for stabilty setup first.

%[big_obj3,aperture3,fourier_error3,initial_obj3,initial_aperture3] = DRb(ePIE_inputs, 0.6, 0.02, 0.7);
%[big_obj3,aperture3,fourier_error3,initial_obj3,initial_aperture3] = DRb(ePIE_inputs, 0.8, 0.05, .7);
[big_obj3,aperture3,fourier_error3,initial_obj3,initial_aperture3] = DRb(ePIE_inputs, 0.6, 0.05, 0.8);
%% show results
% .87 .98 1, 0 0.02 0.05 for 40_300
% 1 0.97 0.97
obj = big_obj(221:520,181:480);
obj2 = big_obj2(221:520,181:480);
obj3 = big_obj3(221:520,181:480);

min1 = min(abs(obj(:))) +0.0; max1 = max(abs(obj(:)));
min2 = min(abs(obj2(:)))+0.0; max2 = max(abs(obj2(:)));
min3 = min(abs(obj3(:)))+0.0; max3 = max(abs(obj3(:)));

figure(12);img(obj,'colormap','gray','caxis',[min1 max1]);
%set(gca, 'visible', 'off');
figure(22);img(obj2,'colormap','gray','caxis',[min2 max2]);
%set(gca, 'visible', 'off');
figure(32);img(obj3,'colormap','gray','caxis',[min3 max3]);
%set(gca, 'visible', 'off');

figure(11);img(big_obj,'colormap','gray','caxis',[min1 max1]);
%set(gca, 'visible', 'off');
figure(21);img(big_obj2,'colormap','gray','caxis',[min2 max2]);
%set(gca, 'visible', 'off');
figure(31);img(big_obj3,'colormap','gray','caxis',[min3*1.2 max3]);
%set(gca, 'visible', 'off');

%%
% rec_px_size = 5.5274e-09;%m
% scale_bar_length2 = 500e-9;
% scale_bar_length3 = 200e-9;
% 
% [ys2, xs2] = size(big_obj);
% [ys3, xs3] = size(obj);
% 
% x_pos2 = 0.6;
% y_pos2 = 0.97;
% x_pos3 = 0.6;
% y_pos3 = 0.97;
% 
% 
% figure(11);hold on;
% line([round(xs2*x_pos2) round(xs2*x_pos2 + scale_bar_length2 ./ rec_px_size)],...
%     [round(ys2*y_pos2) round(ys2*y_pos2)], 'LineWidth', 10, 'Color', 'k');
% hold off;
% 
% figure(12);hold on;
% line([round(xs3*x_pos3) round(xs3*x_pos3 + scale_bar_length3 ./ rec_px_size)],...
%     [round(ys3*y_pos3) round(ys3*y_pos3)], 'LineWidth', 10, 'Color', 'k');
% hold off;


