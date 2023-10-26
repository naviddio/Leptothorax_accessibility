clear all; close all

cd '...\Empirical data\img_RN22' %location of the image sequence for the specified colony

dinfo = dir;
A = {dinfo.name};

A = A(~cellfun('isempty', strfind(A,'.jpg')));

A=sort_nat(A); % sort the image sequence so that it is read in the correct order
activity = [];

noa_all=[56 20 136 29 47 35 38 119 13 64 38 50 32 28 40 19 91 109 96]; % The number of ants in all 19 colonies. From left to right and increasing: RN1, RN2,  RN3 ... RN23

noa =  109; %Set this value to the colony size of the colony being analyzed.  

% rect = [80.5 5.5 271 271]; % Uncomment for RN1, comment out this line when processing other colonies: crops nest in images of colony RN1
% rect = [155.5 5.5 271 271]; % Uncomment for RN2, comment out this line when processing other colonies: crops nest in images of colony RN2
% rect = [25.5 5.5 271 271]; % Uncomment for RN3, comment out this line when processing other colonies: crops nest in images of colony RN3
% rect = [170.5 5.5 271 271]; % Uncomment for RN5, comment out this line when processing other colonies: crops nest in images of colony RN5
% rect = [88.5 10 271 271]; % Uncomment for RN6, comment out this line when processing other colonies: crops nest in images of colony RN6
% rect = [82.5 10 271 271]; % Uncomment for RN7, comment out this line when processing other colonies: crops nest in images of colony RN7
% rect = [95.5 5.5 271 271]; % Uncomment for RN8, comment out this line when processing other colonies: crops nest in images of colony RN8
% rect = [84.5 10 271 271]; % Uncomment for RN10, comment out this line when processing other colonies: crops nest in images of colony RN10
% rect = [130.5 10 271 271]; % Uncomment for RN11, comment out this line when processing other colonies: crops nest in images of colony RN11
% rect = [133.5 10 271 271]; % Uncomment for RN12, comment out this line when processing other colonies: crops nest in images of colony RN12
% rect = [153.5 5.5 271 271]; % Uncomment for RN13, comment out this line when processing other colonies: crops nest in images of colony RN13
% rect = [175.5 10 271 271]; % Uncomment for RN14, comment out this line when processing other colonies: crops nest in images of colony RN14
% rect = [54.5 10 271 271]; % Uncomment for RN17, comment out this line when processing other colonies: crops nest in images of colony RN17
% rect = [182.5 10 271 271]; % Uncomment for RN18, comment out this line when processing other colonies: crops nest in images of colony RN18
% rect = [92.5 10 271 271]; % Uncomment for RN19, comment out this line when processing other colonies: crops nest in images of colony RN19
% rect = [110.5 5.5 271 271]; % Uncomment for RN20, comment out this line when processing other colonies: crops nest in images of colony RN20
% rect = [92.5 5.5 271 271]; % Uncomment for RN21, comment out this line when processing other colonies: crops nest in images of colony RN21
% rect = [67.5 5.5 271 271]; % Uncomment for RN22, comment out this line when processing other colonies: crops nest in images of colony RN22
% rect = [129.5 7.5 271 271]; % Uncomment for RN23, comment out this line when processing other colonies: crops nest in images of colony RN23

 parfor m=1:length(A)-1 %loop though all image pairs
%  for m=1:length(A)-1

    m

    file=[char(A(m))];  % Set filename of 1st frame in pair
    file2=[char(A(m+1))];  % Set filename of 2nd frame in pair

    image=imread(file);
    image=rgb2gray(image); % convert 1st frame to grayscale   
    image=imcrop(image,rect);
    is=image;
    image=imbinarize(image, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 1st image. 0.3 for RN17; 0.39 for RN5; 0.45 for RN21; 0.4 otherwise
    image=imcomplement(image);

    image2=imread(file2); % process 2nd image in the same way as 1st image
    image2=rgb2gray(image2);
    image2=imcrop(image2,rect);
    is2=image2;
    image2=imbinarize(image2, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 2nd image. 0.3 for RN17; 0.39 for RN5; 0.45 for RN21; 0.4 otherwise
    image2=imcomplement(image2);

    s = bwareaopen(image,50,8); % filter noise from 1st image   
    e = bwareaopen(image2,50,8); % filter noise from 2nd image 
     
    start=sum(s(:)); % count number of pixels in 1st image 
    % pixel difference between images
    p=e-s; 
    p(p<0) = 0; 
    
    p = bwareaopen(p,50,8); % filter noise
    ia = e & s; % find pixels that were classified as being part of ants that did not change between the pair of images
    ia = bwareaopen(ia,50,8); % filter noise 
    
    % optional plotting of nest images and segmented ants 
%         figure(1) 
%         imshow(is)
%         figure(2)
%         imshow(s)
%         figure(3)
%         imshow(is2)
%         figure(4)
%         imshow(e)
%         figure(5)
%         imshow(p)
%         figure(6)
%         imshow(ia)
%     w=waitforbuttonpress()

    
    activity(m)=sum(p(:))/start; % estimate proportion of ants that have moved
     
    %partition the segmented nest image of inactive ants into a regular grid with sectors of equal area 
    mfun = @(block_struct) sum(sum(block_struct.data));
    block_inactiveants = blockproc(ia, [68 68], mfun); % sectors are 68x68 pixels. sectors of 68x136 and 68x34 were also used for colony RN22
    


    
    %determine maximum local density (MLD) by finding the number of ant classified pixels in the sector with the most ants. This value is divided by the approx. number of pixels that comprise an ant (see main text).    
    mld(m)=max(max(block_inactiveants))/80; % divide by 80 for L. AF-can, divide by 62 otherwise

    hours(seconds((m)*30))
 end

mld=mld;
v=array2table(horzcat(mld', (mld./noa)', activity'));
v.Properties.VariableNames ={'MLD' 'pMLD' 'activity'}

% save data
% writetable(v, 'activity_MLD_RN22.csv') 

% figure % plot mld vs. activity
% plot(activity)
% figure
% scatter(activity,mld)
