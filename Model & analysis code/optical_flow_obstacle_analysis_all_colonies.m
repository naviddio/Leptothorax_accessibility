clear all; close all
rng(19) %set rng for reproducibility

opticFlow = opticalFlowFarneback %Initialize optical flow settings

colonies=readtable('...\Empirical data\Table_S1.csv');

rects =[80.5 5.5 271 271; 155.5 5.5 271 271; 25.5 5.5 271 271; 170.5 5.5 271 271; ... % ROIs used to crop out the nests of each colony for image analysis
    88.5 10 271 271; 82.5 10 271 271;95.5 5.5 271 271;84.5 10 271 271;130.5 10 271 271; ...
    133.5 10 271 271; 153.5 5.5 271 271; 175.5 10 271 271; 54.5 10 271 271; 182.5 10 271 271; ...
    92.5 10 271 271; 110.5 5.5 271 271; 92.5 5.5 271 271; 67.5 5.5 271 271; 129.5 7.5 271 271];

for n = 1:length(colonies.Colony) % Loop through all colonies
    
    colony_id=char(colonies.Colony(n));
    ofdir=strcat('...\Empirical data\',colony_id, '_cycle_image');
    cd(ofdir)
    
    dinfo = dir;
    A = {dinfo.name};
    A = A(~cellfun('isempty', strfind(A,'imgof')));
    A=sort_nat(A);
    
    point=round(numel(A)/2); % set the location of the one-minute segment for analysis as the midpoint of the activity cycle 

rect = rects(n,:); % ROI used to crop out nest for image analysis
m=[];
v=[];
m2=[];
for i=point-30:point+30 % loop through image sequence and compute optical flow magnitudes
    frame = imread(strcat('imgof_', num2str(i),'.jpg'));
    frame = imcrop(frame,rect);
    frame = im2gray(frame);  
    flow = estimateFlow(opticFlow,frame);
    
%     figure(2)
%     imshow(frame)
%     hold on
%     plot(flow,'DecimationFactor',[10 10],'ScaleFactor',2);
%     hold off
%     w=waitforbuttonpress

speed=flow.Magnitude;
    speed(speed<1.5)=0; % filter out noise in the optical flow magnitudes
    
if strcmp(colony_id,'RN17')
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.3); % threshold 1st frame
image=imcomplement(image);
s = bwareaopen(image,50,8); % filter noise from 1st frame
elseif strcmp(colony_id,'RN5')
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.39); % threshold 1st frame
image=imcomplement(image);
s = bwareaopen(image,50,8); % filter noise from 1st frame
elseif strcmp(colony_id,'RN21')
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.45); % threshold 1st frame
image=imcomplement(image);
s = bwareaopen(image,50,8); % filter noise from 1st frame
else
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 1st frame
image=imcomplement(image);
s = bwareaopen(image,50,8); % filter noise from 1st frame
end
    

    m = cat(3,m,speed);
        m2=cat(3,m2,s);
end

m(:,:,1)=[]; % Remove the first layer of the multidimensional flow magnitudes array. Since pairs of frames are needed to estimate optical flow, this first layer of the multidimensional array is not correct because it only uses the first image in the sequence.    
z = sum(m,3); % sum the optical flow magnitudes associated with each pixel 

z2 = sum(m2,3);

zi=z2;
zi(zi<55)=0; % classify pixels as belonging to inactive ants by finding pixels that had a value of 1 for at least 90% of frames in the 1-min interval (55/61 is closest to 90% without being under 90%)
ia = logical(zi);
ia = bwareaopen(ia,50,8);
 
% extract the optical flow magnitudes for the pixels classified as comprising inactive ants 
k = find(ia);
x = z(k); 
    
y = z(randi(numel(z),[numel(k) 1])); % extract the optical flow magnitudes of random pixels (the number of randomly extracted pixels is equal to the number of detected inactive ant pixels)
    
% generate boxplot
idxd=[];
idxd=horzcat(x,y);
figure
% set(gcf,'Position',[100 100 510 400])
boxplot(idxd, 'symbol', '', 'Colors','kk')
ax = gca;
ax.TickLabelInterpreter = 'tex';
set(gca,'xticklabel',{'Inactive ants', 'Random locations'})
ylabel('Optical flow magnitude')
set(gca,'fontsize',20)
set(gca,'linewidth',2)
set(gca,'TickDir','out')
set(gca, 'FontName', 'Times')

is2=frame;

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


n

cd '...\Empirical data'

idxd_table=array2table(idxd); % save data
idxd_table.Properties.VariableNames ={'Inactive_ants' 'Random_locations'}
% writetable(idxd_table,'Optical_flow_in_nest_all_colonies_1min.xls','Sheet',colony_id)

end