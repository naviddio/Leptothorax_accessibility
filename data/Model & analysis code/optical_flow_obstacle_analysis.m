clear all; close all
cd 'C:\...\Empirical data\RN23_optical_flow_images' %location of the empirical data

rng(19) %set rng for reproducibility

dinfo = dir;
A = {dinfo.name};
A = A(~cellfun('isempty', strfind(A,'.jpg')));
A=sort_nat(A);

opticFlow = opticalFlowFarneback %Initialize optical flow settings

file=[char(A(1))];  % Set filename of 1st frame in pair
image=imread(file);
rect = [323.5 21.5 684 693]; % ROI used to crop out nest for image analysis

m=[];
for i=1:length(A) % loop through image sequence and compute optical flow magnitudes 
    frame = imread(char(A(i)));
    frame = imcrop(frame,rect);
    frame = im2gray(frame);  
    flow = estimateFlow(opticFlow,frame);
    
%     figure(1)
%     imshow(frame)
%     hold on
%     plot(flow,'DecimationFactor',[10 10],'ScaleFactor',2);
%     hold off
%     w=waitforbuttonpress

    m = cat(3,m,flow.Magnitude);

end

m(:,:,1)=[]; % Remove the first layer of the multidimensional flow magnitudes array. Since pairs of frames are needed to estimate optical flow, this first layer of the multidimensional array is not correct because it only uses the first image in the sequence.    
z = sum(m,3); % sum the optical flow magnitudes associated with each pixel 
figure
imshow(uint8(z)) % visualize the amount of activity in the nest (brighter regions correspond to areas with greater amounts of detected motion)

file=[char(A(1))];  % Set filename of 1st frame in pair
file2=[char(A(end))];  % Set filename of 2nd frame in pair

image=imread(file); % process 1st image
image=rgb2gray(image); % convert 1st frame to grayscale
image=imcrop(image,rect);
is=image;
image=imbinarize(image, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 1st image
image=imcomplement(image);

image2=imread(file2); % process 2nd image in the same way as 1st image
image2=rgb2gray(image2);
image2=imcrop(image2,rect);
is2=image2;
image2=imbinarize(image2, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 2nd image
image2=imcomplement(image2);

s = bwareaopen(image,400,8); % filter noise from 1st image       
e = bwareaopen(image2,400,8); % filter noise from 2nd image 
ia= e & s; % find pixels that were classified as being part of ants that did not change between the first and last images in the image sequence 
 
% extract the optical flow magnitudes for the pixels classifed as comprising inactive ants 
k = find(ia);
x = z(k); 
    
y = z(randi(numel(z),[numel(k) 1])); % extract the optical flow magnitudes of random pixels (the number of randomly extracted pixels is equal to the number of detected inactive ant pixels)
    
% generate boxplot
idxd=horzcat(x,y);
a = .05;
b = -.05;
r1 = (b-a).*rand(length(idxd),1) + a;

r2 = (b-a).*rand(length(idxd),1) + a;


figure
% set(gcf,'Position',[100 100 510 400])
boxplot(idxd, 'symbol', '', 'Colors','kk')
% boxplot(idxd,'OutlierSize',0.0001, 'Colors','kk')
h985 = findobj('Tag','boxplot');
set(h985.Children,'LineWidth',1)
ax = gca;
ax.TickLabelInterpreter = 'tex';
set(gca,'xticklabel',{'Inactive ants', 'Random locations'})
ylabel('Optical flow magnitude')
set(gca,'fontsize',20)
set(gca,'linewidth',2)
set(gca,'TickDir','out')
set(gca, 'FontName', 'Times')

figure 
imshow(ia) % visualize the locations of pixels that were classified as making up parts of ants that did not move during the 2.8 min observation interval

% writematrix(idxd,'Optical_flow_in_nest.csv') %Save data