addpath('functions\');
addpath('data\');
ap_radius    = 50;
scaning_step = 51;
%phases = importdata('model.mat'); small_phase = phases(129:256,129:256);
phase = im2double(imread('pepper.png')); phase = double(phase(:,:,1));  phase = padarray(phase,[128,128],0,'both');
model = im2double(imread('cameraman.png')); model = double(model(:,:,1)); model = padarray(model,[128,128],0,'both');

[a, ~, centerx, centery] = make_apertures(model,scaning_step,ap_radius,1e6,'grid',3,120,120);
[N1,N2,nProbes] = size(a);
%a = a.*repmat(exp(1i*(rand(N1,N2)-.5)),[1,1,nProbes]);

%% generate diffraction patterns with poisson noise
% flux
flux=1e8;
dp = zeros([N1,N2,nProbes]);
dp0 = zeros([N1,N2,nProbes]);
for ii = 1:nProbes
    dp0(:,:,ii) = abs(fftshift(fftn(model.*exp(1i*(2*pi*phase-pi)).*a(:,:,ii)))).^2;
    dpi = dp0(:,:,ii);
    scale = flux/sum(dpi(:));
    dp(:,:,ii) = poissrnd(dpi*scale)./scale;
end
%% inputs
object = model.*exp(1i*(2*pi*phase-pi)); object = object(129:256,129:256);

ePIE_inputs.GpuFlag = 0;
ePIE_inputs.Patterns = dp;
ePIE_inputs.Positions = [centerx' centery'];
ePIE_inputs.FileName = 'ePIE_cameraman';
ePIE_inputs.PixelSize = 1;
ePIE_inputs.InitialObj = 0;
ePIE_inputs.ApRadius = ap_radius;
ePIE_inputs.InitialAp = 0;
ePIE_inputs.Iterations = 200;
ePIE_inputs.showim = 1;
ePIE_inputs.updateAp = 1;

noise = sum(sum(abs(sqrt(dp(:)) - sqrt(dp0(:))))) / sum(sum(sqrt(dp0(:))));
fprintf('Noise = %f\n',noise);

%% ePIE reconstruction
ePIE_inputs.Iterations = 400;
ePIE_inputs.do_posi = 0;
ePIE_inputs.FileName = 'ePIE_test';
[big_obj, aperture, fourier_error, initial_obj, initial_aperture]  = ePIE(ePIE_inputs,1,0.01);

%% rPIE reconstruction
ePIE_inputs.Iterations = 400;
ePIE_inputs.FileName = 'rPIE_test';
[big_obj2,aperture2,fourier_error2,initial_obj2,initial_aperture2] = rPIE(ePIE_inputs,0.1,0.02);

%% DR reconstruction
ePIE_inputs.Iterations = 400;
ePIE_inputs.FileName = 'DR_test';
[big_obj3,aperture3,fourier_error3,initial_obj3,initial_aperture3] = DRb(ePIE_inputs,0.7,0.01,0.9, 0, 0.05, 0.4);


%% result of ePIE
correlation1 = normxcorr2(abs(object),abs(big_obj));
h1 = round(size(big_obj)/2);
max1 = max(max(abs(correlation1(h1-128:h1+127,h1-128:h1+127)) ));
I = find(correlation1==max1);
[I1,I2] = ind2sub(size(correlation1),I);

object1 = big_obj(I1-size(object,1)+1:I1, I2-size(object,2)+1:I2 );
%object1 = big_obj(I1-size(object,1)+2:I1+1, I2-size(object,2)+2:I2+1 );

figure(11); img(object1,'colormap','gray');
set(gca, 'visible', 'off');


shift1 = sum(conj(object1(:)).*object(:)); shift1 = shift1/norm(shift1);
angle1 = angle(object1*shift1); 
figure(12); img(angle1,'colormap','gray','abs','off');
set(gca, 'visible', 'off');

%% result of rPIE
correlation2 = normxcorr2(abs(object),abs(big_obj2));
max1 = max(max(abs(correlation2(h1-128:h1+127,h1-128:h1+127)) ));
I = find(abs(correlation2-max1)<eps);
[I1,I2] = ind2sub(size(correlation2),I);

object2 = big_obj2(I1-size(object,1)+1:I1, I2-size(object,2)+1:I2 );
%object2 = big_obj2(I1-size(object,1)+2:I1+1, I2-size(object,2)+2:I2+1 );


figure(21); img(object2,'colormap','gray');
set(gca, 'visible', 'off');

shift2 = sum(conj(object2(:)).*object(:)); shift2 = shift2/norm(shift2);
angle2 = angle(object2*shift2); 
figure(22); img(angle2,'colormap','gray','abs','off');
set(gca, 'visible', 'off');

%% result of sDR
correlation3 = normxcorr2(abs(object),abs(big_obj3));
max1 = max(max(abs(correlation3(h1-128:h1+127,h1-128:h1+127)) ));
I = find(correlation3==max1);
[I1,I2] = ind2sub(size(correlation3),I);

object3 = big_obj3(I1-size(object,1)+1:I1, I2-size(object,2)+1:I2 );
%object3 = big_obj3(I1-size(object,1)+2:I1+1, I2-size(object,2)+2:I2+1 );


figure(31); img(object3,'colormap','gray');
set(gca, 'visible', 'off');

shift3 = sum(conj(object3(:)).*object(:)); shift3 = shift3/norm(shift3);
angle3 = angle(object3*shift3); 
figure(32); img(angle3,'colormap','gray','abs','off');
set(gca, 'visible', 'off');


%%
sphase = im2double(imread('pepper.png')); sphase = double(sphase(:,:,1)); 
smodel = im2double(imread('cameraman.png')); smodel = double(smodel(:,:,1));
figure(101); img(sphase,'colormap','gray','abs','off');
set(gca, 'visible', 'off');
figure(102); img(smodel,'colormap','gray','abs','off');
set(gca, 'visible', 'off');




