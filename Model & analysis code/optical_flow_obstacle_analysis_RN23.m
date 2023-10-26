clear all; close all
cd '...\Empirical data\RN23_optical_flow_images'

rng(19) %set rng for reproducibility

dinfo = dir;
A = {dinfo.name};
A = A(~cellfun('isempty', strfind(A,'.jpg')));
A=sort_nat(A);

opticFlow = opticalFlowFarneback %Initialize optical flow settings

rect = [323.5 21.5 684 693]; % ROI used to crop out nest for image analysis

m=[];
m2=[];
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

%     m = cat(3,m,flow.Magnitude);

speed=flow.Magnitude;
    speed(speed<1.5)=0; % filter out noise in the optical flow magnitudes
    
image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 1st frame
image=imcomplement(image);
s = bwareaopen(image,400,8); % filter noise from 1st frame 

% figure
% imshow(s)

    m = cat(3,m,speed);
    m2=cat(3,m2,s);

end

m(:,:,1)=[]; % Remove the first layer of the multidimensional flow magnitudes array. Since pairs of frames are needed to estimate optical flow, this first layer of the multidimensional array is not correct because it only uses the first image in the sequence.    
z = sum(m,3); % sum the optical flow magnitudes associated with each pixel 

z2 = sum(m2,3);

zi=z2;
zi(zi<151)=0; % classify pixels as belonging to inactive ants by finding pixels that had a value of 1 for at least 90% of frames in the 2.8-min interval (151/167 is closest to 90% without being under 90%)
ia = logical(zi);
ia = bwareaopen(ia,400,8);

 
% extract the optical flow magnitudes for the pixels classified as comprising inactive ants 
k = find(ia);
x = z(k); 
    
y = z(randi(numel(z),[numel(k) 1])); % extract the optical flow magnitudes of random pixels (the number of randomly extracted pixels is equal to the number of detected inactive ant pixels)

idxd=horzcat(x,y);
   
% generate boxplot
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

% figure 
% imshow(ia) % visualize the locations of pixels that were classified as making up parts of ants that did not move during the 2.8 min observation interval

file2=[char(A(end))];  % Set filename of last frame in the 2.8-min segment
image2=imread(file2); % process last frame in the same way as 1st frame
image2=rgb2gray(image2);
image2=imcrop(image2,rect);
is2=image2;

rgbim = ind2rgb(uint8(z), hot(256)); figure % visualize the amount of activity in the nest (brighter regions correspond to areas with greater amounts of detected motion)
q1=imshow(rgbim);
set(q1,'AlphaData', .9)
hold on
q=imshow(is2)
set(q,'AlphaData', 1/3)
rgbim2 = ind2rgb(uint8(rescale(ia,0,50)), turbo(255));
hold on
q2=imshow(rgbim2);
set(q2,'AlphaData', 1/3)

idxd_table=array2table(idxd); % save data
idxd_table.Properties.VariableNames ={'Inactive_ants' 'Random_locations'}
% writetable(idxd_table,'Optical_flow_in_nest_RN23_R1.csv')