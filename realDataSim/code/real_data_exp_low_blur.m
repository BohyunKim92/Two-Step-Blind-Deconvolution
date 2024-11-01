clear; close all; clc;

% This code simulates our deconvolution algorithm using the image given in the top of Fig. 7.
% The code reads barcode image and go through pre-processing step and
% recover perfectly clean barcode at the end with zero error. 

% loading images
[filepath,~,~] = fileparts(pwd) ;
img_path = strcat(filepath,'/barcode_images');
fun_path = strcat(filepath,'/helper_functions');
addpath(genpath(img_path));
addpath(genpath(fun_path));
%img_pth = strcat(filepath,'/barcode_images','/low_blur_barcode.jpg');
img = imread('low_blur_barcode.jpg'); %indicates barcodes that you want to simulate
img = rgb2gray(img); 
img = double(img)/255;

%% Pre-process data
fprintf('Pre-processing of the data\n');

%---- extracting the middle row of barcode---- %
data = mean(img(500:850,10:end-10)); 
data = data';

%---- finding stretch factor ----%
smoothf = imfilter(data,fspecial('gaussian',5,1), 'same');%smoothing data
upordown = sign(diff(smoothf)); %determine whether derivatives is positive or negative
minflags = [upordown(1)>0; diff(upordown)>0;upordown(end)>0].*(data<0.15);%less than 0.7 because don't want the first and last end of the barcode. 0,7 can be adjusted
minima   = find(minflags);

strfactor =round((minima(end)-minima(1))/94); % stretch factor

% stretch matrix is S
bdryfactor = 10; % adding 0 each side
bdrysize = strfactor*bdryfactor; % boundary size
S = kron(eye(95+2*bdryfactor), ones(strfactor,1)); %kron generate 11,11,11.. matri see the notes. 
M = size(S,1);



%---- put data in the center ----%
middlepoint = (minima(end)-minima(1))/2+minima(1); startpoint = round( middlepoint-M/2);
fcut = 1-data(startpoint:startpoint+M-1);



%---- fit intensity ----%
nbin = 100;
[num, ctr] = hist(fcut, nbin);%num vector value. checks how high each bar from the histogram is.
[tmp, idx] = sort(num(1:25), 'descend');%check first 25 numbers and find the max
low = ctr(idx(1)); %maximum value
[tmp, idx] = sort(num(end-24:end), 'descend');
high = ctr(nbin+idx(1)-25);%minimum value

data = (fcut-low)/(high-low);


%% Two-Step Method 
fprintf('Applying Two-Step Deconvolution method \n');

%--- calculate estimated k (k_es) and estimated u of first two digit (u_es)---%
cutlength = 20; % cutlength is the length of estimated kernel, in this case any value from 1-25 yielded a perfect recover.
fc = data(bdryfactor*strfactor+1:end-bdryfactor*strfactor);

[k_es,u_es,err,idx] = kernelforl(fc,strfactor,cutlength);

%--- debluring barcode---%
f = fc; %fc is of size 2375 in this case
K = convmtx(k_es, size(f,1));
S = kron(eye(95), ones(strfactor,1)); %kron generate 11,11,11.. matri see the notes. 
A = K(2*cutlength+1:end-2*cutlength,:)*S;
fc = f(cutlength+1:end-cutlength);
dt = 1/norm(A'*A);
lambda =0.001; 
threshold =0.00002;

%--- apply gradient filter ---%
thisu = zeros(95,1);
nextu = min(1,max(0,thisu + dt*(-A'*(A*thisu-fc)-(lambda*thisu))));
iterations = 1;
while (norm(nextu - thisu)/norm(thisu) > threshold)
   thisu = nextu;
   nextu = min(1,max(0,thisu + dt*(-A'*(A*thisu-fc)-(lambda*thisu))));
   iterations = iterations + 1;
end
 
u_es = S*nextu; % estimated barcode signal

%--- calculating the original the gound truth barcode for comparison ---%
u0 = upc2signal('070662138038'); %95 dimension vector; 
u0 = u0'; 
u = S*u0;

x = 1:1:length(u);
figure; plot(x,u,'r','LineWidth', 3); hold on; plot(x,u_es, 'b','LineWidth', 3);
legend('Deblurred barcode', 'Ground Truth');
ylim([-0.2 1.2])
x0=10;
y0=10;
width=550*1.25;
height=400*1.25;
set(gcf,'position',[x0,y0,width,height])
set(gca,'FontSize',20);
title('Barcode comparison before thresholding')

figure; plot(x,u_es-u,'b', 'LineWidth', 3);
legend('Error of Recovery before thresholding');
ylim([-1.2 1.2])
x0=10;
y0=10;
width=550*1.25;
height=400*1.25;
set(gcf,'position',[x0,y0,width,height])
set(gca,'FontSize',20);

%--- recover the exact barcode by thresholding  ---%
n = length(u_es);
for m = 1: n
    if u_es(m) <= 0.5
        u_es(m) = 0;
    else
        u_es(m) = 1;
    end
end

figure;plot(x,u_es-u,'b', 'LineWidth', 3); 
legend('Error of Recovery after thresholding')
ylim([-1.2,1.2])
x0=10;
y0=10;
width=550*1.25;
height=400*1.25;
set(gcf,'position',[x0,y0,width,height])
set(gca,'FontSize',20);

%--- adjust figures to be consistent---%
figure; plot(x,u,'r','LineWidth', 3);hold on; plot(x,u_es,'b', 'LineWidth', 3); 
legend('Ground Truth','Thresholded barcode');
ylim([-0.2 1.2])
x0=10;
y0=10;
width=550*1.25;
height=400*1.25;
set(gcf,'position',[x0,y0,width,height])
set(gca,'FontSize',20);
title('Barcode comparison after thresholding')

