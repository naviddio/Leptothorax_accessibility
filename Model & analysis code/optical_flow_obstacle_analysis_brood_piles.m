clear all; close all

colonies=readtable('...\Empirical data\Table_S1.csv');

rng(19) %set rng for reproducibility

% define the regions corresponding to brood piles in all 19 colonies
rects =[240.5 93.5 99  149; 138.5 80.5 99 149; 150.5 120.5 99 149; 253.5 181.5 149 99; ... 
    70.5 159.5 149 99; 83.5 168.5 149 99; 75.5100 100.5100 99 149; 150.5 100.5 99 149; 130.5 70.5 99 149; ...
    221.5 150.5 149 99; 169.5 174.5 149 99; 199.5 175.5 149 99; 127.5 52.5 149 99; 215.5 115.5 149 99; ...
    188.5 113.5 99 149; 270.5 80.5 99 149; 155.5 130.5 99 149; 225.5 98.5 99 149; 218.5 170.5 149 99];

for n = 1:length(colonies.Colony) % loop through all colonies
    
    colony_id=char(colonies.Colony(n));
    ofdir=strcat('...\Empirical data\',colony_id, '_cycle_image');
    cd(ofdir)
    
    dinfo = dir;
    A = {dinfo.name};
    A = A(~cellfun('isempty', strfind(A,'imgof')));
    A=sort_nat(A);
    
        m=[];
m2=[];
activity_ants=[];
activity_ring = [];
nia=[];
brood_coverage=[];
opticFlow = opticalFlowFarneback %Initialize optical flow settings
for j=1:length(A)/30-1
    m=[];
m2=[];
for i=((j-1)*30:(j-1)*30+30)+1 % loop through 30-second intervals of the image sequence and compute optical flow magnitudes 
    frame = imread(char(A(i)));
    frame = im2gray(frame);  
    is= imcrop(frame,rects(n,:));
    is2=is;
    flow = estimateFlow(opticFlow,is);
    
%     figure(1)
%     imshow(is)
%     hold on
%     plot(flow,'DecimationFactor',[10 10],'ScaleFactor',2);
%     hold off
%     w=waitforbuttonpress

if strcmp(colony_id,'RN18')
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.3); % threshold frame; 0.3 for colony RN18, 0.4 otherwise
else
    image=imbinarize(frame, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold frame; 0.3 for colony RN18, 0.4 otherwise
end
    image=imcomplement(image);
    s = bwareaopen(image,50,8);
    s = imcrop(s,rects(n,:));
    
%     figure(1)
%     imshow(is)
%     figure(2)
%     imshow(s)
%     w=waitforbuttonpress

speed=flow.Magnitude;
    speed(speed<1.5)=0; % filter out noise in the optical flow magnitudes
% 
    m = cat(3,m,speed);
m2=cat(3,m2,s);
    i

end

if j == 1 
m(:,:,1)=[]; % Remove the first layer of the multidimensional flow magnitudes array. Since pairs of frames are needed to estimate optical flow, this first layer of the multidimensional array is not correct because it only uses the first image in the sequence.    
end
z = sum(m,3); % sum the optical flow magnitudes associated with each pixel 
zr=z;
za=z;

z2 = sum(m2,3);

zi=z2;
zi(zi<28)=0; % classify pixels as belonging to inactive ants by finding pixels that had a value of 1 for at least 90% of frames in the 30-sec interval (28/31 is closest to 90% without being under 90%) 
ia = logical(zi);
ia = bwareaopen(ia,50,8);
AS=sparse(ia);
[y,x] = find(AS);

se = strel('square',10); % create structuring element for binary dilation
    ia2=imdilate(ia,se);    
    ia_ring=ia2-ia;
    AS2=sparse(ia_ring);
% [y,x] = find(AS2); % optional plotting; the area immediatly adjacnet to inactive ants will appear green 
% plot(x,y,'.g')


nia(j)=nnz(ia); % count the number of pixels classifed as inactive ants 

mfun = @(block_struct) sum(sum(block_struct.data));
    block_activity = blockproc(logical(z), [10 10], mfun); % sectors in the brood pile are set to 10x10 pixels.
    
    brood_coverage(j) = nnz(block_activity)/numel(block_activity); % calculate the proportion of sectors that contain non-zero optical flow magnitudes (i.e., activity)
        
        zr(ia_ring==0)=0; %Extract optical flow magnitudes for all pixels that are adjacent to inactive ants (i.e., in the added dilation)
        za(ia==0)=0; %Extract optical flow magnitudes for all pixels classified as inactive ants
        
%         axis off
% figure
% z=rescale(z,0,256);
% rgbim = ind2rgb(uint8(z), hot(256)); % visualize the amount of activity in the nest (brighter regions correspond to areas with greater amounts of detected motion)
% q1=imshow(rgbim);
% set(q1,'AlphaData', .98)
% hold on
% q=imshow(is2)
% set(q,'AlphaData', 0.5)
% rgbim2 = ind2rgb(uint8(rescale(ia,0,50)), turbo(255));
% hold on
% q2=imshow(rgbim2);
% set(q2,'AlphaData', 1/3)
% rgbim3 = ind2rgb(uint8(rescale(ia_ring,0,50)), copper(255));
% hold on
% q3=imshow(rgbim3);
% set(q3,'AlphaData', 1/3)
        
        activity_ring(j)=sum(zr,'all'); % Find the sum of the optical flow magnitudes from all pixels that are adjacent to inactive ants (i.e., in the added dilation) 
        activity_ants(j)=sum(za,'all'); % Find the sum of the optical flow magnitudes from all pixels that are classified as inactive ants
end
cd '...\Empirical data'

if sum(strcmp(colony_id,{'RN5' 'RN6' 'RN7' 'RN21'}))==1 %convert no. of pixels to approx. number of inactive ants
worker_size = 62; %62 pixels per ant for L. retractus
else
worker_size = 80; %80 pixels per ant for L. canadensis & L. AF-erg
end

figure(99) % generate scatter plot of pile coverage vs. number of inactive ants in pile 
subplot(5,4,n)
scatter(nia./worker_size,brood_coverage, 300, '.k')
ylim([0 1])
h2 = lsline;
h2.LineWidth = 2;
h2.Color = 'k';
set(gca,'fontsize',10)
set(gca,'linewidth',2)
set(gca,'TickDir','out')
set(gca, 'FontName', 'Times')
ylabel('Pile coverage')
xlabel('No. of inactive ants in pile')
title(colonies.Colony(n))

idxd_table=array2table(horzcat((nia./worker_size)',brood_coverage')); % save data
idxd_table.Properties.VariableNames ={'No_of_inactive_ants' 'Brood_coverage'}
writetable(idxd_table,'Optical_flow_brood_pile_coverage_v.xls','Sheet',colony_id)

idxd=horzcat(activity_ants',activity_ring');
% generate boxplot
figure
set(gcf,'Position',[100 100 300 300])
boxf=boxplot(idxd, 'symbol', '', 'Colors','kk')
set(gca,'xticklabel',{'Inactive ants', 'Adjacent locations'})
ylabel('Optical flow magnitude')
set(gca,'fontsize',10)
set(gca,'linewidth',2)
set(gca,'TickDir','out')
set(gca, 'FontName', 'Times')
hold on
parallelcoords(idxd, 'Color', [0.5 0.5 0.5], 'Marker', '.', 'MarkerSize', 12);
hold off
title(colonies.Colony(n))
% saveas(gcf,strcat(colony_id, '_coverage_box_S.svg'));
figure

idxd_table=array2table(idxd); % save data
idxd_table.Properties.VariableNames ={'Inactive_ants' 'Adjacent_locations'}
writetable(idxd_table,'Optical_flow_brood_pile_barrier_v.xls','Sheet',colony_id)


size_crop(n)=sum(size(z));
end