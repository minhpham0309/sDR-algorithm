addpath('functions\');
addpath('data\');
%% USAF data
load 'ePIE_inputs_20180226-SCF_USAF_laser_2.mat'
npats = size(ePIE_inputs.Positions,1);
% randomly pick 50% data
index = randperm(npats,round(npats*.5));


%% inputs
ePIE_inputs.FileName = 'DR_test';
ePIE_inputs.GpuFlag = 0;
ePIE_inputs.Patterns = ePIE_inputs.Patterns(:,:,index);
ePIE_inputs.Positions = ePIE_inputs.Positions(index,:);
ePIE_inputs.updateAp = 1;
ePIE_inputs.showim = 1;
ePIE_inputs.Iterations = 300;

%% ePIE reconstruction
[big_obj,aperture,fourier_error,initial_obj,initial_aperture] = ePIE(ePIE_inputs,1,0.5);

%% rPIE reconstruction
[big_obj2,aperture2,fourier_error2,initial_obj2,initial_aperture2] = rPIE(ePIE_inputs,0.1,1);

%% DR reconstruction
% parameters:
% beta_obj = 0.9
% beta_ap  = 0.5
% momentum = 0.3

[big_obj3,aperture3,fourier_error3,initial_obj3,initial_aperture3] = DRb(ePIE_inputs, 0.9, .5, .3);

%}
%%
[size1,size2] = size(big_obj3);
half1 = floor(size1/2);
w = 135;
c1 = half1-w+1; c2 = half1+w;
figure(11); img(big_obj (c1:c2,c1:c2),'caxis',[0,1],'colormap','gray');
set(gca, 'visible', 'off');
figure(21); img(big_obj2(c1:c2,c1:c2),'colormap','gray');
set(gca, 'visible', 'off');
figure(31); img(big_obj3(c1:c2,c1:c2),'colormap','gray');
set(gca, 'visible', 'off');

%% scale bar
[ys, xs] = size(big_obj3(c1:c2,c1:c2));
rec_px_size = 5.386e-6;%m 
scale_bar_length = 200e-6;
x_pos = 0.65;
y_pos = 0.97;
hold on;
line([round(xs*x_pos) round(xs*x_pos + scale_bar_length ./ rec_px_size)],...
    [round(ys*y_pos) round(ys*y_pos)], 'LineWidth', 10, 'Color', 'k');
hold off;
set(gca, 'visible', 'off');


